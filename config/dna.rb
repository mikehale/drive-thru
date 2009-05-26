require 'rubygems'
require 'json'

dna = {
  :recipes => [
    "openssh",
    "git",
    "mysql::server", 
    "apache2", "apache2::mod_rails"
    "passenger", 
    "rsync", 
    "postfix"
   ]
}

open(File.dirname(__FILE__) + "/dna.json", "w").write(dna.to_json)