require 'rubygems'
require 'activeresource'

# Get your API key from your SliceManager here:
# https://manage.slicehost.com/api/
# and put it here:
API_PASSWORD = ENV['API_PASSWORD'] unless Object.const_defined?('API_PASSWORD')

# Address class is required for Slice class 
class Address < String; end

# Define the ActiveResource classes
class Slice < ActiveResource::Base 
  self.site = "https://#{API_PASSWORD}@api.slicehost.com/" 
  def self.find_by_name(name)
    Slice.find(:first, :params => { :name => name })    
  end
end 

class Zone < ActiveResource::Base 
  self.site = "https://#{API_PASSWORD}@api.slicehost.com/" 
  
  def records
    Record.find(:all, :params => { :zone_id => self.id })
  end
  
  def self.exists?(name)
    !Zone.find(:all, :params => { :origin => name }).empty?
  end
  
  def self.find_by_name(name)
    Zone.find(:first, :params => { :origin => name })
  end
end 

class Record < ActiveResource::Base 
  self.site = "https://#{API_PASSWORD}@api.slicehost.com/" 
end

# Method to add a new record based on a hash
def create_record(r, defaults)
  rec = Record.new(defaults.merge(r))
  rec.save
  puts notice(rec)
end

# Prints the record's details
def notice(r)
  ' | ' + r.name.to_s.ljust(30) + 
  ' | ' + r.record_type.to_s.ljust(5) + 
  ' | ' + r.aux.to_s.rjust(4) + 
  ' | ' + r.data.to_s.ljust(34) + 
  ' | '
end

desc "configure dns information at slicehost"
task :setup_dns do
  if Zone.exists?(ZONE_NAME)
    Zone.find_by_name(ZONE_NAME).destroy
  end

  # Create new zone
  z = Zone.new(:origin => ZONE_NAME, :ttl => 3600)
  z.save

  # Record definitions 
  defaults = { :zone_id => z.id, :ttl => 3600 }

  a_records = [
    { :record_type => 'A', :name => ZONE_NAME,        :data => ZONE_IP },
    { :record_type => 'A', :name => "*.#{ZONE_NAME}", :data => ZONE_IP }
  ]
  
  txt_records = [
    { :record_type => 'TXT', :name => ZONE_NAME, :data => 'v=spf1 include:aspmx.googlemail.com ~all' }
  ]

  google_mx = [
    { :record_type => 'MX', :name => ZONE_NAME, :aux => 10, :data => 'ASPMX.L.GOOGLE.COM.'      },
    { :record_type => 'MX', :name => ZONE_NAME, :aux => 20, :data => 'ALT1.ASPMX.L.GOOGLE.COM.' },
    { :record_type => 'MX', :name => ZONE_NAME, :aux => 20, :data => 'ALT2.ASPMX.L.GOOGLE.COM.' },
    { :record_type => 'MX', :name => ZONE_NAME, :aux => 30, :data => 'ASPMX2.GOOGLEMAIL.COM.'   },
    { :record_type => 'MX', :name => ZONE_NAME, :aux => 30, :data => 'ASPMX3.GOOGLEMAIL.COM.'   },
    { :record_type => 'MX', :name => ZONE_NAME, :aux => 30, :data => 'ASPMX4.GOOGLEMAIL.COM.'   },
    { :record_type => 'MX', :name => ZONE_NAME, :aux => 30, :data => 'ASPMX5.GOOGLEMAIL.COM.'   }
  ]

  google_cname = [
    { :record_type => 'CNAME', :name => 'mail',     :data => 'ghs.google.com.' },
    { :record_type => 'CNAME', :name => 'start',    :data => 'ghs.google.com.' },
    { :record_type => 'CNAME', :name => 'docs',     :data => 'ghs.google.com.' },
    { :record_type => 'CNAME', :name => 'calendar', :data => 'ghs.google.com.' }
  ]  

  google_srv = [
    { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{ZONE_NAME}", :aux => 5, :data => '0 5269 xmpp-server.l.google.com.'},
    { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server1.l.google.com.'},
    { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server2.l.google.com.'},
    { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server3.l.google.com.'},
    { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server4.l.google.com.'},
    { :record_type => 'SRV', :name => "_jabber._tcp.#{ZONE_NAME}", :aux => 5, :data => '0 5269 xmpp-server.l.google.com.'},
    { :record_type => 'SRV', :name => "_jabber._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server1.l.google.com.'},
    { :record_type => 'SRV', :name => "_jabber._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server2.l.google.com.'},
    { :record_type => 'SRV', :name => "_jabber._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server3.l.google.com.'},
    { :record_type => 'SRV', :name => "_jabber._tcp.#{ZONE_NAME}", :aux => 20, :data => '0 5269 xmpp-server4.l.google.com.'}
  ]

  ns_records = [
    { :record_type => 'NS', :name => ZONE_NAME, :data => 'ns1.slicehost.net.' },
    { :record_type => 'NS', :name => ZONE_NAME, :data => 'ns2.slicehost.net.' },
    { :record_type => 'NS', :name => ZONE_NAME, :data => 'ns3.slicehost.net.' }
  ]

  # DO IT!!

  puts "\nCreating A records..."
  a_records.each do |r|
    create_record(r, defaults)
  end

  puts "\nCreating TXT records..."
  txt_records.each do |r|
    create_record(r, defaults)
  end

  puts "\nCreating NS records..."
  ns_records.each do |r|
    create_record(r, defaults)
  end

  puts "\nCreating Google MX records..."
  google_mx.each do |r|
    create_record(r, defaults)
  end

  puts "\nCreating Google SRV records..."
  google_srv.each do |r|
    create_record(r, defaults)
  end

  puts "\nCreating Google CNAME records..."
  google_cname.each do |r|
    create_record(r, defaults)
  end

  # Finally, let everyone know we're finished
  puts "\nALL DONE!"
end