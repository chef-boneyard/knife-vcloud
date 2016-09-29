#
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.
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

$:.unshift File.expand_path("../../lib", __FILE__)

require "chef/knife/winrm_base"
require "winrm"
require "em-winrm"
require "chef"
require "fog"

require "chef/knife/vcloud_base"
require "chef/knife/vcloud_server_create"
require "chef/knife/vcloud_server_delete"
require "chef/knife/vcloud_server_list"
require "knife-vcloud/version"

require "securerandom"
require "tmpdir"
require "fileutils"
require File.expand_path(File.dirname(__FILE__) + "/utils/knifeutils")
require File.expand_path(File.dirname(__FILE__) + "/utils/matchers")

def temp_dir
  @_temp_dir ||= Dir.mktmpdir
end

def match_status(test_run_expect)
  if "#{test_run_expect}" == "should fail"
    should_not have_outcome :status => 0
  elsif "#{test_run_expect}" == "should succeed"
    should have_outcome :status => 0
  elsif "#{test_run_expect}" == "should return empty list"
    should have_outcome :status => 0
  else
    should have_outcome :status => 0
  end
end

def create_file(file_dir, file_name, data_to_write_file_path)
  data_to_write = File.read(File.expand_path("#{data_to_write_file_path}", __FILE__))
  File.open("#{file_dir}/#{file_name}", "w") { |f| f.write(data_to_write) }
  puts "Creating: #{file_name}"
end
