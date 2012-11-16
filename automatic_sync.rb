#!env ruby

require File.expand_path(File.dirname(__FILE__) + '/repository')
#require './repository'

['/home/rob/n'].each do |dir|
  Repository.sync(dir)
end
