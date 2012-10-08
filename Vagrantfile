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

      #EC2 provisioning
      require 'json'
      open('chef/dna.json', 'w') do |f|
        chef.json[:run_list] = chef.run_list
        f.write chef.json.to_json
      end
      open('chef/run_list', 'w') do |f|
        run_list = chef.run_list.map{|x|
          x.gsub('recipe', '').gsub(/(\[|\])/, '').gsub(/::.*$/, '')
        }.uniq

        run_list.map { |recipe|
          f.puts "cookbooks/#{recipe}"
        }
      end
    end
  end
end