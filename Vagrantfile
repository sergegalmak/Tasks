# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
config.vm.box = "bertvv/centos72"
config.vm.boot_timeout = 300

config.vm.provider "virtualbox" do |vb|
	vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
	
end



config.vm.define "vm1" do |vm1|
	config.vm.provider :virtualbox do |vb|
		vb.name = "vm1"
		vb.memory = "512"
		#vb.gui = true
	end

	
	vm1.vm.hostname = "vm1"
	#config.vm.network :public_network, :public_network => "wlan0"
	#vm1.vm.network "private_network", type: "dhcp"
	vm1.vm.network "private_network", ip: "172.28.128.11"
	#config.vm.network "forwarded_port", guest: 22, host: 2222, host_ip: "127.0.0.1", id: 'ssh'
	


vm1.vm.provision "shell", 
	inline: <<-SHELL
	yum install mc -y
	yum install git -y
	grep 'dns' /etc/hosts || echo '172.28.128.11 vm1' >> /etc/hosts
	grep 'dns' /etc/hosts || echo '172.28.128.12 vm2' >> /etc/hosts
	mkdir /home/vagrant/git
	cd /home/vagrant/git
	git clone https://github.com/sergegalmak/vagrant.git ./
	git checkout task2
	git branch -v
	cat task2
	
SHELL
end

config.vm.define "vm2" do |vm2|
	config.vm.provider :virtualbox do |vb|
		vb.name = "vm2"
		vb.memory = "512"
		#vb.gui = true
	end
		
	
	vm2.vm.hostname = "vm2"
	#vm2.vm.network "private_network", type: "dhcp"
	vm2.vm.network "private_network", ip: "172.28.128.12"
	

vm2.vm.provision "shell", 
	inline: <<-SHELL
	yum install mc -y
	grep 'dns' /etc/hosts || echo '172.28.128.11 vm1' >> /etc/hosts
	grep 'dns' /etc/hosts || echo '172.28.128.12 vm2' >> /etc/hosts
SHELL

end
end





