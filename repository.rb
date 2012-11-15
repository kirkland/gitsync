class Repository
  REMOTE_SYNC_HOST = "rob@robmk.com"
  REMOTE_REPO_PATH = "/home/rob/gitsync_repos"

  def initialize(repo_path)
    @repo_path = repo_path

    raise "#{@repo_path} not a directory" unless File.directory? @repo_path
    raise "#{@repo_path} not a git repository" unless File.directory? "#{@repo_path}/.git"
  end

  def commit_all_files
    commit_message = %{Automatic commit for #{Time.now.strftime("%Y-%m-%d")}.}
    repo_run "git add .", %{git commit -m "#{commit_message}"}
  end

  def remote_configured?
    repo_run %{git remote | grep -E '^gitsync$'}
  end

  def create_remote_repo
    remote_run "cd #{REMOTE_REPO_PATH}", "git init --bare #{repo_name}.git"
  end

  def set_remote
    repo_run "git remote add gitsync #{REMOTE_SYNC_HOST}:#{REMOTE_REPO_PATH}/#{repo_name}"
  end

  def push
    repo_run "git push gitsync master"
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
    system %{ssh #{REMOTE_SYNC_HOST} '#{join_commands(commands)}'}
  end
end
