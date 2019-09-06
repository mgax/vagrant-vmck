# -*- mode: ruby -*-
# vi: set ft=ruby :

 Vagrant.configure("2") do |config|
  config.vm.box = "base"

   if Vagrant.has_plugin?('vagrant-env')
    config.env.enable
  end

   config.nfs.functional = false

   config.vm.provision 'shell', inline: "mv /vagrant/submission.zip .; unzip submission.zip; chown -R vagrant:vagrant ."

   config.vm.provider :vmck do |vmck|
    vmck.vmck_url = ENV["VMCK_URL"]
  end
end

