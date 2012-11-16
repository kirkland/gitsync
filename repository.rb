class Repository
  REMOTE_SYNC_HOST = "rob@robmk.com"
  REMOTE_REPO_PATH = "/home/rob/gitsync_repos"

  def initialize(repo_path)
    @repo_path = repo_path

    raise "#{@repo_path} not a directory" unless File.directory? @repo_path
    raise "#{@repo_path} not a git repository" unless File.directory? "#{@repo_path}/.git"
  end

  def commit_all_files
    if repo_run "ls CONFLICT"
      puts "Found a CONFLICT file, aborting."
      return false
    else
      puts "no CONFLICT found"
    end

    commit_message = %{Automatic commit on #{hostname} for #{Time.now.strftime("%Y-%m-%d")}.}
    repo_run "git add -A", %{git commit -m "#{commit_message}"}
    true
  end

  def remote_configured?
    repo_run %{git remote | grep -E '^gitsync$'}
  end

  def create_remote_repo
    remote_run "cd #{REMOTE_REPO_PATH}", "git init --bare #{repo_name}.git"
  end

  def set_remote
    if `hostname` =~ /robmk/
      repo_run "git remote add gitsync #{REMOTE_REPO_PATH}/#{repo_name}"
    else
      repo_run "git remote add gitsync #{REMOTE_SYNC_HOST}:#{REMOTE_REPO_PATH}/#{repo_name}"
    end
  end

  def log_error(message)
    puts message
  end

  def pull
    result = repo_run "git pull --rebase gitsync master"
    if !result
      log_error("Error during pull --rebase for #{@repo_path}")
      repo_run "echo Error during pull --rebase > CONFLICT"
      repo_run "git rebase --abort"
      return false
    end

    true
  end

  def push
    repo_run "git push gitsync master"
    true
  end

  def remote_repo_exists?
    remote_run "cd #{REMOTE_REPO_PATH}", "stat #{repo_name}.git"
  end

  def setup_sync
    should_push = false

    if !remote_repo_exists?
      should_push = true
      create_remote_repo
    end

    if !remote_configured?
      should_push = true
      set_remote
    end

    push if should_push
    true
  end

  def self.sync(repo_path)
    new(repo_path).sync
  end

  def sync
    setup_sync && commit_all_files && pull && push
  end

  private

  def repo_name
    @repo_path.split('/').last
  end

  def join_commands(commands)
    commands.join(' && ')
  end

  def run(*commands)
    system join_commands(commands)
  end

  def repo_run(*commands)
    run("cd #{@repo_path}", *commands)
  end

  def remote_run(*commands)
    if `hostname` =~ /robmk/
      run(*commands)
    else
      system %{ssh #{REMOTE_SYNC_HOST} '#{join_commands(commands)}'}
    end
  end

  def hostname
    `hostname`.chomp
  end
end
