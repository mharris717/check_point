require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def make_temp_dir
  i = (rand()*1000000000000.0).to_i
  res = "#{CheckPoint.root}/tmp/#{i}"
  ec "mkdir #{res}", silent: true
  res
end

class MakeDir
  include FromHash

  def initialize(ops={})
    from_hash(ops)
    ec "git --git-dir=#{repo} --work-tree=#{root} init", silent: true
  end

  fattr(:root) do
    make_temp_dir
    #ec "git --git-dir=#{repo} --work-tree=#{res} init", silent: true
    #res
  end

  fattr(:repo) do
    #res = make_temp_dir
    #res = "#{res}/.git"
    #ec "mkdir #{res}", silent: true
    #res
    res = "#{root}/.gitcp"
    ec "mkdir #{res}", silent: true
    res
  end

  def git(cmd)
    ec "git --git-dir=#{repo} --work-tree=#{root} #{cmd}", silent: true
  end

  def file(path,body,ops={})
    full = "#{root}/#{path}"
    File.create full,body
    if ops[:commit] != false
      git "add #{path}"
      git "commit -m CS"
    end
  end

  def git_obj
    Git.open(root, repository: repo, index: "#{repo}/index")
  end
end

describe "CheckPoint" do
  it 'smoke' do
    2.should == 2
    CheckPoint.should be
  end

  it 'make dir' do
    d = MakeDir.new
    d.file "a.txt","abc"
    File.read("#{d.root}/a.txt").should == "abc"
    d.git_obj.status.changed.size.should == 0
    d.git_obj.status.deleted.size.should == 0

    d.file "a.txt","xyz", commit: false
    d.git_obj.status.changed.size.should == 1
    # require 'pp'
    # pp d.git_obj.status
    # puts d.git :status


    # res = d.git :status
    # res.should == "zzz"

    # ec "cd #{d.repo} && ls"
  end

  it 'checkout smoke' do
    d = MakeDir.new
    d.file "a.txt","abc"

    d.git "checkout -b m2"
    d.file "b.txt","def"

    Dir["#{d.root}/*"].size.should == 2

    d.git "checkout master"
    Dir["#{d.root}/*"].size.should == 1
  end

  it 'thing' do
    d = MakeDir.new
    d.file "a.txt","abc"

    d.git "checkout -b m2"
    d.file "b.txt","def"

    tmp = make_temp_dir
    git = Git.open(tmp, repository: d.repo, index: "#{d.repo}/index")
    git.reset_hard
    git.checkout(:master)
    #ec "git --git-dir=#{d.repo} --work-tree=#{tmp} reset --hard"
    # ec "git --git-dir=#{d.repo} --work-tree=#{tmp} checkout master"
    

    Dir["#{d.root}/*"].size.should == 2
    Dir["#{tmp}/*"].size.should == 1
  end

  it 'track' do
    d = MakeDir.new
    d.file "a.txt","abc"

    track = CheckPoint::Track.new(working_dir: d.root, repo_dir: d.repo)
    File.create "#{d.root}/b.txt", "def"
    track.commit!
  end

  it 'track2' do
    dir = make_temp_dir
    ec "cd #{dir} && git init"
    File.create "#{dir}/a.txt","abc"
    ec "cd #{dir} && git add a.txt && git commit -m CS"

    track = CheckPoint::Track.new(working_dir: dir)
    track.commit!

    File.create "#{dir}/b.txt", "def"
    track.commit!

    track.commit!

    # ec "git --work-tree=#{track.working_dir} --git-dir=#{track.repo_dir} log"

    # track.repo.gcommit('master')
    track.repo.diff("master","master^").size.should == 1
  end
end
