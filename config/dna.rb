require 'rubygems'
require 'json'

dna = {}

open(File.dirname(__FILE__) + "/dna.json", "w").write(dna.to_json)