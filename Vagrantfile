# Every Vagrant development environment requires a box. You can search for
# boxes at https://vagrantcloud.com/search.
box = "ubuntu/bionic64"

ansible_playbook = [
    { :name => "Containerd", :path => "playbook-1.yml" },
    { :name => "Kubernetes", :path => "playbook-2.yml" }
]

ansible_inventory_path = "inventory/hosts"
ssh_key = "~/.ssh/id_rsa"

nodes   =   [
    { :hostname => "master-node", :ip => "192.168.56.2", :group => "master", :memory => 2048, :cpu => 2, :guest => 22, :host => "27101" },
    { :hostname => "worker-node01", :ip => "192.168.56.3", :group => "worker", :memory => 2048, :cpu => 1, :guest => 22, :host => "27102" },
    { :hostname => "worker-node02", :ip => "192.168.56.4", :group => "worker", :memory => 2048, :cpu => 1, :guest => 22, :host => "27103" }
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

    if File.dirname(ansible_inventory_path) != "."
        Dir.mkdir(File.dirname(ansible_inventory_path)) unless Dir.exist?(File.dirname(ansible_inventory_path))
    end

    File.open(ansible_inventory_path, 'w') do |f|
        nodes.each do |node|
            if node[:group] != "master"
                f.write "[#{node[:group]}]\n"
                f.write "#{node[:hostname]} ansible_host=#{node[:ip]} ansible_user=vagrant ansible_ssh_private_key_file=#{ssh_key}\n"
            else
                f.write "[#{node[:group]}]\n"
                f.write "#{node[:hostname]} ansible_host=#{node[:ip]} ansible_user=vagrant ansible_ssh_private_key_file=#{ssh_key}\n"
            end
        end

        f.write "\n"
        f.write "[all]\n"
        nodes.each do |cfg|
            f.write "#{node[:hostname]}\n"
        end
    end

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
            conf.vm.provision "forward-ipv4", type: "shell", :path => "ipv4_forward.sh"

            conf.ssh.private_key_path = ["~/.vagrant.d/insecure_private_key", ssh_key]
            conf.ssh.insert_key = false
            conf.vm.provision "file", source: ssh_key + ".pub", destination: "~/.ssh/authorized_keys"

            if index == nodes.size - 1
                ansible_playbook.each do |play|
                    conf.vm.provision :ansible do |ansible|
                        ansible.inventory_path = ansible_inventory_path
                        ansible.verbose = "v"
                        ansible.limit = "all"
                        ansible.playbook = play[:path]
                    end
                end
            end
        end
    end
end