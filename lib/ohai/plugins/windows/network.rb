#
# Author:: James Gartrell (<jgartrel@gmail.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:Network) do
  provides "network", "network/interfaces"
  provides "counters/network", "counters/network/interfaces"

  def windows_encaps_lookup(encap)
    return "Ethernet" if encap.eql?("Ethernet 802.3")
    encap
  end

  collect_data(:windows) do
    require 'ruby-wmi'

    iface = Mash.new
    network Mash.new unless network
    network[:interfaces] = Mash.new unless network[:interfaces]
    #counters Mash.new unless counters
    #counters[:network] = Mash.new unless counters[:network]

    networks = wmi.instances_of('Win32_NetworkAdapterConfiguration')

    networks.each_with_index do |network, index|
      next if !network['ipaddress']
      ipv4 = network['ipaddress'].map{|ip| ip if ip =~ Resolv::IPv4::Regex }.compact
      ipv6 = network['ipaddress'].map{|ip| ip if ip =~ Resolv::IPv6::Regex }.compact
      iface[index][:configuration][:mac_address] = [network['macaddress']]
      iface[index][:description] = network['description']
      
      if ipv6.any?
        ipv6.each do |ip| 
          iface[index][:addresses][ip][:family] = "inet6"
          iface[index][:addresses][ip][:scope] = "Link" if ip =~ /^fe80/i
        end
      elsif ipv4.any?
        ipv4.each do |ip| 
          iface[index][:addresses][ip][:family] = "inet"
        end
      end
      
      [iface[index][:configuration][:mac_address]].flatten.each do |mac_addr|
        iface[index][:addresses][mac_addr] = { "family" => "lladdr" }
      end
    end
    
    network[:interfaces] = iface
  end
end
