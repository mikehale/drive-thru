# Run `rake initialize_host` once to:
# * add your ssh key to the server
# * setup dns for your zone including google hosted apps and SPF records
# * install chef-solo
# * and finally run your recipes on the remote box

# Run `rake` after updating your site-cookbooks or your dna.rb to apply the latest changes to your box.

TOPDIR = File.expand_path(File.dirname(__FILE__))

ZONE_NAME = "example.com."
ZONE_IP = "a.b.c.d"
API_PASSWORD = "" # from manage.slicehost.com
HOST = ZONE_IP
HOST_LOGIN="root@#{HOST}"
RSYNC="rsync -avz --delete --delete-excluded --exclude '.*'"

load 'sprinkle_chef/Rakefile'
load 'lib/dns.rb'

desc "Create dna.json from dna.rb file"
task :create_dna  do
  dna_file = File.join(File.dirname(__FILE__), "config", "dna.rb")
  raise "There is no config/dna.rb file! Take care of that!" unless File.exists? dna_file 
  sh "ruby #{dna_file}"
end

task :update_config => :create_dna do
  remote("mkdir -p /etc/chef")
  sh "#{RSYNC} #{TOPDIR}/config/* #{HOST_LOGIN}:/etc/chef/"
  File.delete(File.dirname(__FILE__) + "/config/dna.json")
end

desc "rsync the cookbooks to #{HOST}"
task :update_cookbooks do
  remote("mkdir -p /var/chef")
  ['site-cookbooks', 'cookbooks'].each do |name|
    sh "#{RSYNC} --exclude=openldap --exclude=quick_start #{File.join(TOPDIR, name)}/ #{HOST_LOGIN}:/var/chef/#{name}"
  end
end

desc "Run chef-solo on #{HOST}"
task :run_chef_solo => [:update_config, :update_cookbooks] do
  command = "chef-solo -j /etc/chef/dna.json -c /etc/chef/solo.rb"
  command << " -l debug" if ENV['DEBUG'] == 'true' 
  remote(command)
end

task :install_custom_chef do
  sh "#{RSYNC} chef-0.6.2.gem #{HOST_LOGIN}:"
  remote "gem install chef-0.6.2.gem"
end

def remote(cmd)
  sh "ssh #{HOST_LOGIN} '#{cmd}'"
end

task :default => :run_chef_solo

desc "Automatically initialze #{HOST} from scratch. You should only have to enter the root password once."
task(:initialize_host => ['add_ssh_key', 'setup_dns', 'chef:solo', 'install_custom_chef', 'run_chef_solo']) {}
