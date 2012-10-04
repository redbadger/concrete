# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :build do |build_config|
    build_config.vm.box = "precise64"
    build_config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    build_config.vm.network :hostonly, "192.168.50.10"
    build_config.vm.host_name = "build.local"

    build_config.vm.provision :chef_solo do |chef|
      chef.add_recipe "ohai"
      chef.add_recipe "apt"
      chef.add_recipe "git"
      chef.add_recipe "nginx" # https://github.com/opscode-cookbooks/nginx
      chef.add_recipe "nodejs" # https://github.com/mdxp/nodejs-cookbook
      chef.add_recipe "mongodb::10gen_repo"
      chef.add_recipe "mongodb" # https://github.com/edelight/chef-mongodb
      chef.json = {
        "nodejs" => {
          "install_method" => "package"
        } 
      }
    end
  end

  config.vm.define :web do |web_config|
    web_config.vm.box = "precise64"
    web_config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    web_config.vm.network :hostonly, "192.168.50.20"
    web_config.vm.host_name = "web01.local"
  end
end