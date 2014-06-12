#
# Author:: Kris Forbes (<kris.forbes@ssc-spc.gc.ca>)
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

Ohai.plugin(:Memory) do
  provides "memory"

  collect_data(:windows) do
    
    require 'wmi-lite/wmi'
    
    wmi = WmiLite::Wmi.new
    os = wmi.instances_of('Win32_OPeratingSystem')
    
    memory Mash.new
    
    memory[:free] = os[0]['freephysicalmemory']
    memory[:total] = os[0]['totalvisiblememorysize']
    memory[:active] = os[0]['totalvisiblememorysize'].to_i - os[0]['freephysicalmemory'].to_i
  end
end