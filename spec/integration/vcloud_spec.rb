# Copyright: Copyright (c) 2012 Opscode, Inc.
# License: Apache License, Version 2.0
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

# Author:: Ameya Varade (<ameya.varade@clogeny.com>)

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

def init_test
  #We may not need knife.rb for now but we might need while writing create, list, delete test cases.
  puts "\nCreating Test Data\n"
  create_file("#{temp_dir}", "validation.pem", "../integration/config/validation.pem" )
  create_file("#{temp_dir}", "knife.rb", "../integration/config/knife.rb")
end

def cleanup_test_data
  puts "\nCleaning Test Data\n"
  FileUtils.rm_rf("#{temp_dir}")
  puts "\nDone\n"
end

def get_gem_file_name
  "knife-vcloud-" + KnifeVCloud::VERSION + ".gem"
end

describe "knife-vcloud" do
  include RSpec::KnifeUtils
  before(:all) { init_test }
  after(:all) { cleanup_test_data }
  context "gem" do
    context "build" do
      let(:command) { "gem build knife-vcloud.gemspec" }
      it "should succeed" do
        match_status("should succeed")
      end
    end

    context "install " do
      let(:command) { "gem install " + get_gem_file_name }
      it "should succeed" do
        match_status("should succeed")
      end
    end

    describe "knife" do
      context "vcloud" do
        context "image list --help" do
          let(:command) { "knife vcloud image list --help" }
          it "should succeed" do
            should have_outcome :stdout => /--help/
          end
        end
        context "network list --help" do
          let(:command) { "knife vcloud network list --help" }
          it "should succeed" do
            should have_outcome :stdout => /--help/
          end
        end

        context "server create --help" do
          let(:command) { "knife vcloud server create --help" }
          it "should succeed" do
            should have_outcome :stdout => /--help/
          end
        end

        context "server delete --help" do
          let(:command) { "knife vcloud server delete --help" }
          it "should succeed" do
            should have_outcome :stdout => /--help/
          end
        end

        context "server list --help" do
          let(:command) { "knife vcloud server list --help" }
          it "should succeed" do
            should have_outcome :stdout => /--help/
          end
        end
      end
    end

    context "uninstall " do
      let(:command) { "gem uninstall knife-vcloud -v '#{KnifeVCloud::VERSION}'" }
      it "should succeed" do
        match_status("should succeed")
      end
    end
  end
end
