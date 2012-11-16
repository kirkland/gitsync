#!env ruby

require File.expand_path(File.dirname(__FILE__) + '/repository')

["#{ENV['HOME']}/n"].each do |dir|
  Repository.sync(dir)
end
