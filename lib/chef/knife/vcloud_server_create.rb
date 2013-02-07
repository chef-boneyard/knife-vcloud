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
require 'chef/knife/vcloud_base'
require 'highline'
require 'chef/knife'

class Chef
  class Knife
    class VcloudServerCreate < Knife

      include Knife::VcloudBase

      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife vcloud server create NAME [RUN LIST...] (options)"

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template; default is 'ubuntu10.04-gems'",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "ubuntu10.04-gems"

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
        :default => false

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node",
        :proc => Proc.new { |t| Chef::Config[:knife][:chef_node_name] = t }

      option :image,
        :short => "-I IMAGE_ID",
        :long => "--vcloud-image IMAGE_ID",
        :description => "Your VCloud virtual app template/image name",
        :proc => Proc.new { |template| Chef::Config[:knife][:image] = template }

      option :vcpus,
        :long => "--vcpus VCPUS",
        :description => "Defines the number of vCPUS per VM. Possible values are 1,2,4,8",
        :proc => Proc.new { |vcpu| Chef::Config[:knife][:vcpus] = vcpu }

      option :memory,
        :short => "-m MEMORY",
        :long => "--memory MEMORY",
        :description => "Defines the number of MB of memory. Possible values are 512,1024,1536,2048,4096,8192,12288 or 16384.",
        :proc => Proc.new { |memory| Chef::Config[:knife][:memory] = memory }

      option :vcloud_network,
        :long => "--network NETWORK_ID",
        :description => "vCloud vOrg/vApp network",
        :proc => Proc.new { |network| Chef::Config[:knife][:vcloud_network] = network }

      option :ssh_password,
          :short => "-p PASSWORD",
          :long => "--password PASSWORD",
          :description => "SSH Password for the user",
          :proc => Proc.new { |password| Chef::Config[:knife][:ssh_password] = password }


      def h
        @highline ||= HighLine.new
      end

      def tcp_test_ssh(hostname, port)
        tcp_socket = TCPSocket.new(hostname, port)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
     rescue Errno::ENETUNREACH
        sleep 2
        false
     rescue Errno::ECONNRESET
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

      def run
        $stdout.sync = true
        validate!

        vcpus = locate_config_value(:vcpus)
        memory = locate_config_value(:memory)
        password = locate_config_value(:ssh_password)

        server_spec = {
            :name =>  locate_config_value(:chef_node_name)
        }
        catalog = connection.catalogs.each do |catalog|
            catalog_items = catalog.catalog_items
            catalog = catalog_items.find{|catalog_item|
              catalog_item.href.scan(locate_config_value(:image)).size > 0 }
            if catalog
                server_spec[:catalog_item_uri] = catalog.href
                break
            end
        end

        if server_spec[:catalog_item_uri].nil?
            ui.error("Cannot find Image in the Catalog: #{image}")
            exit 1
        end

        network = connection.networks.all.find {|n|
          n.href.scan(locate_config_value(:vcloud_network)).size > 0 }
        if network.nil?
          ui.error("Cannot find network : #{locate_config_value(:vcloud_network)}")
        end
        server_spec[:network_uri] = network.href

        vapp = connection.servers.create(server_spec)
        print "Instantiating Server(vApp) named #{h.color(vapp.name, :bold)} with id #{h.color(vapp.href.split('/').last.to_s, :bold)}"
        print "\n#{ui.color("Waiting for server to be Instantiated", :magenta)}"

        # wait for it to be ready to do stuff
        vapp.wait_for { print "."; ready? }
        puts("\n")
        #Fetch additional vApp information (incl. networking, children etc)
        vapp = connection.get_vapp(vapp.href)

        #Fetch the associated VM information for further configuration
        server = connection.get_server(vapp.children[:href])
        server.network={:network_name => network.name, :network_mode => "POOL" }
        server.password
        server.password = password
        server.save

        print "\n#{ui.color("Configuring the server as required", :magenta)}"
        if not vcpus.nil?
          server.cpus
          server.cpus = vcpus
          server.save
        end

        if not memory.nil?
          server.memory
          server.memory = memory
          server.save
        end

        # wait for it to be configure to do stuff
        server.wait_for { print "."; ready? }
        puts("\n")

        #Power On the server
        server.power_on
        # connection.power_on(vapp.href)
        print "\n#{ui.color("Waiting for server to be Powered On", :magenta)}"
        server.wait_for { print "."; on? }
        puts("\n")
        public_ip_address = server.network[:IpAddress]
        puts "#{ui.color("Server Public IP Address", :cyan)}: #{public_ip_address}"
        puts "#{ui.color("Server Password", :cyan)}: #{server.password}"
        print "\n#{ui.color("Waiting for sshd.", :magenta)}"
        puts("\n")
        print(".") until tcp_test_ssh(public_ip_address, "22") { sleep @initial_sleep_delay ||= 10; puts("done") }
        puts "\nBootstrapping #{h.color(server.name, :bold)}..."
        bootstrap_for_node(server.name, public_ip_address).run
      end

      def validate!
        super([
          :vcloud_username, :vcloud_password, :vcloud_url,
          :chef_node_name, :image, :vcloud_network, :ssh_password
        ])
      end

      def bootstrap_for_node(name, fqdn)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [fqdn]
        bootstrap.config[:run_list] = locate_config_value(:run_list)
        bootstrap.config[:ssh_user] = "root"
        bootstrap.config[:ssh_password] = locate_config_value(:ssh_password)
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name) || name
        bootstrap.config[:distro] = locate_config_value(:distro)
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:use_sudo] = false
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap
      end
    end
  end
end
