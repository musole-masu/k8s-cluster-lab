# Every Vagrant development environment requires a box. You can search for
# boxes at https://vagrantcloud.com/search.
box = "ubuntu/bionic64"
ansible_playbook = [
    { :name => "Containerd", :path => "playbook-1.yml" },
    { :name => "Kubernetes", :path => "playbook-2.yml" }
]
nodes   =   [
    { :hostname => "master-node", :ip => "192.168.56.2", :memory => 2048, :cpu => 2, :guest => 22, :host => "27101" },
    { :hostname => "worker-node01", :ip => "192.168.56.3", :memory => 2048, :cpu => 1, :guest => 22, :host => "27102" },
    { :hostname => "worker-node02", :ip => "192.168.56.4", :memory => 2048, :cpu => 1, :guest => 22, :host => "27103" }
]

def configure_dns(node)
    # Set up /etc/hosts
    node.vm.provision "setup-hosts", :type => "shell", :path => "hosts.sh" do |s|
      s.args = ["enp0s8", node.vm.hostname]
    end
    # Set up DNS resolution
    node.vm.provision "setup-dns", type: "shell", :path => "dns.sh"
end

Vagrant.configure("2") do |config|
    # Loop through all nodes to provision vms
    nodes.each_with_index do |node, index|
        box_img = node[:box] ? node[:box] : box
        
        config.vm.define node[:hostname] do |conf|
            conf.vm.box = box_img.to_s
            conf.vm.hostname = node[:hostname]
            conf.vm.network "private_network", ip: node[:ip]
            conf.vm.network "forwarded_port", guest: node[:guest], host: node[:host]

            conf.vm.provider "virtualbox" do |vb|
                vb.name = node[:hostname]
                vb.memory = node[:memory]
                vb.cpus = node[:cpu]
            end

            configure_dns conf

            # Forwarding IPv4 and letting iptables see bridged traffic 
            config.vm.provision "forward-ipv4", type: "shell", :path => "ipv4_forward.sh"

            if index == nodes.size - 1
                ansible_playbook.each do |play|
                    conf.vm.provision :ansible do |ansible|
                        ansible.verbose = "v"
                        ansible.limit = "all"
                        ansible.playbook = play[:path]
                    end
                end
            end
        end
    end
end