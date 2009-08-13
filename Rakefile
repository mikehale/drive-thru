require File.join(File.dirname(__FILE__), 'config', 'rake')
load 'sprinkle_chef/Rakefile'
load 'lib/dns.rb'
load 'lib/chef-repo.rb'

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

def remote(cmd)
  sh "ssh #{HOST_LOGIN} '#{cmd}'"
end

task :default => :run_chef_solo

desc "Automatically initialze #{HOST} from scratch. You should only have to enter the root password once."
dependencies = %w[add_ssh_key]
dependencies << 'setup_dns' unless API_PASSWORD == ""
dependencies << 'chef:solo'
dependencies << 'run_chef_solo'
task(:initialize_host => dependencies) {}
