Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.define "client" do |client|
    client.vm.network "private_network", ip: "192.168.11.150", virtualbox__intnet: "net1"
    client.vm.hostname = "client"
    client.vm.provision "shell", path: "install_script_client.sh"
  end

  config.vm.define "backup" do |backup|
    backup.vm.network "private_network", ip: "192.168.11.160", virtualbox__intnet: "net1"
    backup.vm.hostname = "backup"
    backup.vm.provider "virtualbox" do |vb|
      unless File.exist?('./storage/backup.vdi')
            vb.customize ['createhd', '--filename', './storage/backup.vdi', '--variant', 'Fixed', '--size', 2048]
            needsController = true
      end
      vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]
      vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './storage/backup.vdi']
    end
    backup.vm.provision "shell", path: "install_script_backup.sh"
    
  end

end
