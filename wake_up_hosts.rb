#!/usr/bin/env ruby
#-*- coding: utf-8 -*-
#
# wake_up_hosts.rb
#
# Copyright (c) 2014 Takuma Nakajima
#  
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php
#

require 'optparse'
require 'socket'

# set default options
$config_file = File.expand_path(File.join(ENV['HOME'], '.wol_hosts'))
$dry_run = false
$wol_all = false

# update options by the arguments
OptionParser.new do |opt|
  opt.on("-c FILENAME", "--config FILENAME", "select config file") do |filename|
    $config_file = filename
  end
  opt.on("-d", "--dry-run", "only show the wol command to execute") do
    $dry_run = true
  end
  opt.on("-a", "--all", "send wol packet to all hosts in config file") do
    $wol_all = true
  end
  opt.on("-l", "--list", "show wol hosts in config file") do
    puts open($config_file).read.split(/\n/).reject{|line| line =~ /^\s*#/}
    exit
  end
  opt.parse!(ARGV)
end

if ARGV.empty? and $wol_all == false
  puts "#{$0} -h, --help to show usage."
  exit 1
end

def mac_address?(str)
  not str.scan(/(?:[0-9a-f]{2}[:-]){5}[0-9a-f]{2}/i).empty?
end

def ip_address?(str)
  not str.scan(/(?:[0-9]{1,3}\.){3}[0-9]{1,3}/).empty?
end

def wake_up(mac, broadcast)
  if $dry_run
    puts "[dry-run] Waking up #{mac}... (broadcasting to #{broadcast})"
  else
    puts "Waking up #{mac}... (broadcasting to #{broadcast})"
    message = ['FF'].pack('H2') * 6
    message << mac.split(/[:-]/).pack('H2H2H2H2H2H2') * 16
    udp_sock = UDPSocket.new
    udp_sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
    udp_sock.send(message, 0, broadcast, 7)
  end
end

# the remaining argument is the keyword
keywords = ARGV

# search target hosts matching with the keyword from config_file
if File.exists? $config_file
  hosts = open($config_file).read.split(/\n/).reject{ |line|
    # skip comment line starting with '#'
    line =~ /\s*^#/
  }.map{ |line|
    # each line consists of:
    #   [interface|broadcast_ip] mac_address keywords...
    #   e.g.
    #     eth1           01:23:45:67:89:ab keyword1 keyword2 keyword3
    #     192.168.10.255 01:23:45:67:89:ab keyword1 keyword2 keyword3
    #                    01:23:45:67:89:ab keyword1 keyword2 keyword3
    array = line.split(/\s/)
    if mac_address? array[0]
      {:iface => nil,      :mac => array[0], :keywords => array[1..-1]}
    else
      if ip_address? array[0]
        {:iface => nil, :broadcast_ip => array[0], :mac => array[1], :keywords => array[2..-1]}
      else
        {:iface => array[0], :broadcast_ip => nil, :mac => array[1], :keywords => array[2..-1]}
      end
    end
  }
  targets = hosts.select{ |hash|
    unless $wol_all
      found = false
      keywords.each do |keyword|
        found |= hash[:keywords].index keyword
      end
      found
    else
      true
    end
  }
  if targets.empty?
    puts "There is no host matching the keyword: #{keywords.join(', ')}"
    exit 1
  end
else
  puts "config file not found: #{$config_file}"
  exit 1
end

# send wol packet to each host
targets.each{|hash|
  if hash[:iface]
    broadcast_ip = `ip -4 a show dev #{hash[:iface]} | grep brd | awk '{print $4}'`.chomp
    wake_up(hash[:mac], broadcast_ip)
  elsif hash[:broadcast_ip]
    wake_up(hash[:mac], hash[:broadcast_ip])
  else
    wake_up(hash[:mac], '255.255.255.255')
  end
}

