#!env ruby

require File.expand_path(File.dirname(__FILE__) + '/repository')

['n', 'tcb', 'money', 'yefim', 'levelup', 'journal', 'nala', 'ubonin'].each do |dir|
  begin
    Repository.sync("#{ENV['HOME']}/#{dir}")
  rescue => e
    puts "Oh no, an error! Maybe this is not a directory, or not a repository! exception: #{e.inspect}"
  end
end
