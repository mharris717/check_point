module CheckPoint
  class Track
    include FromHash
    attr_accessor :working_dir
    fattr(:repo_dir) do
      raise "bad" unless working_dir.present?
      "#{working_dir}/.gitcp"
      #{ }"#{make_temp_dir}/sdfsdfsd"
    end

    def ensure_repo_exists!
      return if FileTest.exist?(repo_dir)
      ec "mkdir #{repo_dir}", silent: true
      ec "git --git-dir=#{repo_dir} --work-tree=#{working_dir} init", silent: true
    end

    def has_commits?
      repo.log.size
      true
    rescue => exp
      return false if exp.message =~ /bad default revision/
      return true
    end

    def changes?
      if !has_commits?
        puts "no commits"
        return true 
      end

      s = repo.status
      s.changed.size > 0 || s.deleted.size > 0 || s.added.size > 0 || s.untracked.size > 0
    end

    fattr(:repo) do
      ensure_repo_exists!
      Git.open(working_dir, repository: repo_dir, index: "#{repo_dir}/index")
    end

    def commit!
      ensure_repo_exists!
      return unless changes?
      repo.add(all: true)
      repo.commit_all("CS")
    end
  end
end