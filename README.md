# knife-vcloud

## Description

This is the official Opscode Knife plugin for vcloud. This plugin gives knife the ability to create, bootstrap, and manage servers on the VMWare vCloud Cloud.

## Installation

Be sure you are running the latest version Chef. Versions earlier than 0.10.0 don't support plugins:

```shell
bundle install
```

Depending on your system's configuration, you may need to run this command with root privileges.

## Note

This plugin is under development and not distributed as a Ruby Gem. It depends on the git source of fog. Please use the bundler to use this plugin until the Ruby Gem is released

## Configuration

In order to communicate with the vcloud Cloud API you will have to tell Knife about your Username and API Key. The easiest way to accomplish this is to create some entries in your **knife.rb** file:

```ruby
knife[:vcloud_username] = "Your vCloud Account Username"
knife[:vcloud_password] = "Your vCloud Account Password"
knife[:vcloud_host] = "Your vCloud Server"
```

The vcloud_username typically has the format:

<user-name>@<vcloud-organization-name> eg. 'MyUser@MyvCloudOrg' . The vcloud_host is the IP or FQDN of VMware vCloud Director. eg 'zone01.myvcloud.com'. This information can be extracted from the vCloud portal URL which has the following format: http(s)://<vcloud-host>/cloud/org/<vcloud-organization-name>.</vcloud-organization-name></vcloud-host></vcloud-organization-name></user-name>

You also have the option of passing your vcloud Username/Password into the individual knife subcommands using the **-A** (or **--vcloud-username** ) **-K** (or **--vcloud-password** ) command options

```
# provision a new 2 Core 1GB Ubuntu 10.04 webserver
knife vcloud server create --vcpus 2 -m 1024 -I <Template_ID> -A 'Your vcloud Username' -K "Your vcloud Password" -r 'role[webserver]' --network <Network_ID>

# provision a new Windows 2008 R2 Server with WinRM enabled:
knife vcloud server create -I <Windows_Template_ID> -A 'Your vcloud Username' -K "Your vcloud Password" --network <Network_ID> --bootstrap-protocol winrm
```

The network ID and template ID can be viewed via their respective list commands i.e knife vcloud network list and knife vcloud image list

Additionally the following options may be set in your `knife.rb`:

- distro
- template_file

## Subcommands

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a **--help** flag

### knife vcloud server create

Provisions a new server in the vcloud Cloud and then perform a Chef bootstrap (using the SSH protocol). The goal of the bootstrap is to get Chef installed on the target system so it can run Chef Client with a Chef Server. The main assumption is a baseline OS installation exists (provided by the provisioning). It is primarily intended for Chef Client systems that talk to a Chef server. By default the server is bootstrapped using the {ubuntu10.04-gems}[<https://github.com/opscode/chef/blob/master/chef/lib/chef/knife/bootstrap/ubuntu10.04-gems.erb>] template. This can be overridden using the **-d** or **--template-file** command options.

### knife vcloud server delete

Deletes an existing server in the currently configured vcloud Cloud account by the server/instance id. You can find the instance id by entering 'knife vcloud server list'. Please note - this does not delete the associated node and client objects from the Chef server.

### knife vcloud server list

Outputs a list of all servers in the currently configured vcloud Cloud account. Please note - this shows all instances associated with the account, some of which may not be currently managed by the Chef server.

### knife vcloud image list

Outputs a list of all available images available to the currently configured vcloud Cloud account. An image is a collection of files used to create or rebuild a server. vcloud provides a number of pre-built OS images by default. This data can be useful when choosing an image id to pass to the **knife vcloud server create** subcommand.

### knife vcloud network list

Outputs a list of all available networks to the currently configured vcloud Cloud account. A network can be a Org or vApp level network. This data can be useful when choosing a network id to pass to the **knife vcloud server create** subcommand.

## Contributing

For information on contributing to this project see <https://github.com/chef/chef/blob/master/CONTRIBUTING.md>

## License

Author:: Chirag Jog ([chirag@clogeny.com](mailto:chirag@clogeny.com))

Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.

License:: Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
```
