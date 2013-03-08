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
require 'fog'
class Chef
  class Knife
    module VcloudBase
        # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'chef/knife'
            require 'chef/json_compat'
            Chef::Knife.load_deps
          end

          option :vcloud_password,
            :short => "-K PASSWORD",
            :long => "--vcloud-password PASSWORD",
            :description => "Your VCloud password",
            :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_password] = key }

          option :vcloud_username,
            :short => "-A USERNAME",
            :long => "--vcloud-username USERNAME",
            :description => "Your VCloud username",
            :proc => Proc.new { |username| Chef::Config[:knife][:vcloud_username] = username }

          option :vcloud_host,
           :short => "-U HOST",
           :long => "--vcloud-host HOST",
           :description => "The vCloud API endpoint",
           :proc => Proc.new { |u| Chef::Config[:knife][:vcloud_host] = u }


          option :verify_ssl_cert,
              :long => "--verify-ssl-cert",
              :description => "Verify SSL Certificates",
              :default => false,
              :boolean => true,
              :proc => Proc.new { |u| Chef::Config[:knife][:verify_ssl_cert] = u }

        end
      end

      def connection
        Chef::Log.debug("vcloud_username #{locate_config_value(:vcloud_username)}")
        Chef::Log.debug("vcloud_password #{locate_config_value(:vcloud_password)}")
        Chef::Log.debug("vcloud_host #{locate_config_value(:vcloud_host)}")
        Chef::Log.debug("verify_ssl_cert #{locate_config_value(:verify_ssl_cert)}")

        @connection ||= begin
          connection = Fog::Vcloud::Compute.new(
            :vcloud_username => locate_config_value(:vcloud_username),
            :vcloud_password => locate_config_value(:vcloud_password),
            :vcloud_host => locate_config_value(:vcloud_host),
            :vcloud_version => '1.5',
            :connection_options => {
              :ssl_verify_peer=>locate_config_value(:verify_ssl_cert),
              :connect_timeout => 200,
              :read_timeout => 200,
            }
            )
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate!(keys=[:vcloud_username, :vcloud_password, :vcloud_host])
        errors = []

        keys.each do |k|
          pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
          if locate_config_value(k).nil?
            errors << "You did not provide a valid '#{pretty_key}' value. Please set knife[:#{k}] in your knife.rb or pass as an option."
          end
        end

        if errors.each{|e| ui.error(e)}.any?
          exit 1
        end
      end

    end
  end
end

