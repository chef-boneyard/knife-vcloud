#
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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
require "chef/knife/vcloud_base"
require "fog"
require "highline"
require "chef/knife"
require "chef/json_compat"
require "tempfile"

class Chef
  class Knife
    class VcloudServerList < Knife
      include Knife::VcloudBase

      banner "knife vcloud server list (options)"

      def h
        @highline ||= HighLine.new
      end

      def run
        $stdout.sync = true
        validate!

        server_list = [
            h.color("ID", :bold),
            h.color("Name", :bold),
            h.color("Password", :bold),
            h.color("PublicIP", :bold),
            h.color("PrivateIP", :bold),
            h.color("OperatingSystem", :bold),

        ]
        vapps = connection.vapps.all
        #Fetch each VM (server) info from each vApp available
        if vapps
          vapps.each do |vapp|
            vapp.servers.all.each do |server|
              server_list << vapp.href.split("/").last
              server_list << vapp.name.to_s
              server_list << server.password.to_s
              server_list << server.network[:IpAddress].to_s
              server_list << server.network[:IpAddress].to_s
              server_list << server.operating_system[:"ovf:Description"].to_s
            end
          end
        end
        puts h.list(server_list, :columns_across, 6)
      end
    end
  end
end
