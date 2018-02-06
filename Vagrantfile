# -*- mode: ruby -*-
# vi: set ft=ruby :
$dns = <<END
	grep 'dns' /etc/hosts || echo '172.28.128.21 apache' >> /etc/hosts
	grep 'dns' /etc/hosts || echo '172.28.128.22 tomcat1' >> /etc/hosts
	grep 'dns' /etc/hosts || echo '172.28.128.23 tomcat2' >> /etc/hosts
END

Vagrant.configure("2") do |config|
	config.vm.box = "bertvv/centos72"
	config.vm.boot_timeout = 300
	config.vm.provision "shell", inline: $dns

	config.vm.provider "virtualbox" do |vb|
		vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
	end

	config.vm.define "tomcat1" do |tomcat1|
		config.vm.provider :virtualbox do |vb|
			vb.name = "tomcat1"
			vb.memory = "512"
		end
		
		tomcat1.vm.hostname = "tomcat1"
		tomcat1.vm.network "private_network", ip: "172.28.128.22"
		#tomcat1.vm.network "forwarded_port", guest: 8080, host: 8081, host_ip: "127.0.0.1", id: 'http'
		
		tomcat1.vm.provision "shell", 
			inline: <<-SHELL
			yum install mc -y
			yum install tomcat tomcat-webapps tomcat-admin-webapps -y
			systemctl stop firewalld 
			mkdir /usr/share/tomcat/webapps/test
			echo "tomcat1 172.28.128.22" > /usr/share/tomcat/webapps/test/index.html 
			systemctl enable tomcat 
			systemctl start tomcat 
		SHELL

	end
	config.vm.define "tomcat2" do |tomcat2|		
		config.vm.provider :virtualbox do |vb|
			vb.name = "tomcat2"
			vb.memory = "512"
		end
			
		tomcat2.vm.hostname = "tomcat2"
		tomcat2.vm.network "private_network", ip: "172.28.128.23"
		#tomcat2.vm.network "forwarded_port", guest: 8080, host: 8082, host_ip: "127.0.0.1", id: 'http'
		
		tomcat2.vm.provision "shell", 
			inline: <<-SHELL
			yum install mc -y
			yum install tomcat tomcat-webapps tomcat-admin-webapps -y
			systemctl stop firewalld 
			mkdir /usr/share/tomcat/webapps/test
			echo "tomcat2 172.28.128.23" > /usr/share/tomcat/webapps/test/index.html 
			systemctl enable tomcat 
			systemctl start tomcat 
			
		SHELL
	end
	
	config.vm.define "apache" do |apache|
		config.vm.provider :virtualbox do |vb|
			vb.name = "apache"
			vb.memory = "512"
		end
	
		apache.vm.hostname = "apache"
		apache.vm.network "private_network", ip: "172.28.128.21"
		apache.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1", id: 'http'
	
		apache.vm.provision "shell", 
			inline: <<-SHELL
			yum install mc -y
			yum install git -y
			yum install httpd -y			
			systemctl enable httpd
			systemctl stop firewalld 
			cp /vagrant/mod_jk.so /etc/httpd/modules/
	
			echo	"worker.list=lb
				worker.lb.type=lb
				worker.lb.balance_workers=tomcat1, tomcat2
				worker.tomcat1.host=172.28.128.22
				worker.tomcat1.port=8009
				worker.tomcat1.type=ajp13
				worker.tomcat2.host=172.28.128.23
				worker.tomcat2.port=8009
				worker.tomcat2.type=ajp13
				" > /etc/httpd/conf/workers.properties
			
			echo 	"LoadModule jk_module modules/mod_jk.so
				JkWorkersFile conf/workers.properties
				JkShmFile /tmp/shm
				JkLogFile logs/mod_jk.log
				JkLogLevel info
				JkMount /test* lb
				" >> /etc/httpd/conf/httpd.conf
					
			systemctl start httpd 
		SHELL
	end
	end





