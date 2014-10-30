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

    fattr(:repo) do
      Git.open(working_dir, repository: repo_dir, index: "#{repo_dir}/index")
    end

    def commit!
      ensure_repo_exists!
      repo.add(all: true)
      repo.commit_all("CS")
    end
  end
end