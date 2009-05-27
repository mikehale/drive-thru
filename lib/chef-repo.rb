desc "Create a new cookbook (with COOKBOOK=name, optional CB_PREFIX=site-)"
task :new_cookbook do
  create_cookbook(File.join(TOPDIR, "#{ENV["CB_PREFIX"]}cookbooks"))
end

def create_cookbook(dir)
  raise "Must provide a COOKBOOK=" unless ENV["COOKBOOK"]
  puts "** Creating cookbook #{ENV["COOKBOOK"]}"
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "attributes")}"
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "recipes")}"
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "definitions")}"
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "libraries")}"
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "files", "default")}"
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "templates", "default")}"
  unless File.exists?(File.join(dir, ENV["COOKBOOK"], "recipes", "default.rb"))
    open(File.join(dir, ENV["COOKBOOK"], "recipes", "default.rb"), "w") do |file|
      file.puts <<-EOH
#
# Cookbook Name:: #{ENV["COOKBOOK"]}
# Recipe:: default
#
# Copyright #{Time.now.year}, #{COMPANY_NAME}
#
EOH
      case NEW_COOKBOOK_LICENSE
      when :apachev2
        file.puts <<-EOH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
EOH
      when :none
        file.puts <<-EOH
# All rights reserved - Do Not Redistribute
#
EOH
      end
    end
  end
end