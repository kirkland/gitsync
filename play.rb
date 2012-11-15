def commit_all_files(repo_path)
  raise "#{repo_path} not a directory" unless File.directory? repo_path
  raise "#{repo_path} not a git repository" unless File.directory? "#{repo_path}/.git"

  commit_message = %{Automatic commit for #{Time.now.strftime("%Y-%m-%d")}.}
  command = %{cd #{repo_path} && git add . && git commit -m "#{commit_message}"}

  system command
end
