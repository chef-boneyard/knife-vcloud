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
    class VcloudImageList < Knife
      include Knife::VcloudBase

      banner "knife vcloud image list (options)"

      def h
        @highline ||= HighLine.new
      end

      def run
        validate!
        $stdout.sync = true

        images_list = [ h.color("ID", :bold), h.color("Name", :bold), h.color("Type", :bold) ]
        #There are two types of Catalog - Private and Public. Each of which contains images(catalog items)
        connection.catalogs.each do |catalog|
          catalog.catalog_items.each do |catalog_item|
            images_list << catalog_item.href.split("/").last.to_s
            images_list << catalog_item.name.to_s
            images_list << catalog.name.to_s
          end
        end
        puts h.list(images_list, :columns_across, 3)
      end
    end
  end
end
