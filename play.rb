REMOTE_SYNC_HOST = "rob@robmk.com"
REMOTE_REPO_PATH = "/home/rob/gitsync_repos"


def commit_all_files(repo_path)
  raise "#{repo_path} not a directory" unless File.directory? repo_path
  raise "#{repo_path} not a git repository" unless File.directory? "#{repo_path}/.git"

  commit_message = %{Automatic commit for #{Time.now.strftime("%Y-%m-%d")}.}
  command = %{cd #{repo_path} && git add . && git commit -m "#{commit_message}"}

  system command
end

def has_gitsync_remote?(repo_path)
  system "cd #{repo_path} && git remote | grep -E '^gitsync$'"
end

def repo_name(repo_path)
  repo_path.split('/').last
end

def create_remote_repo(repo_path)
  command = %{ssh #{REMOTE_SYNC_HOST} 'cd #{REMOTE_REPO_PATH} && git init --bare #{repo_name(repo_path)}.git'}

  system command
end

def set_remote(repo_path)
  command = %{cd #{repo_path} && git remote add gitsync #{REMOTE_SYNC_HOST}:#{REMOTE_REPO_PATH}/#{repo_name(repo_path)}}

  system command
end

def push(repo_path)
  command = %{cd #{repo_path} && git push gitsync master}

  system command
end
