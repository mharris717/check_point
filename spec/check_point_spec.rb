require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def make_temp_dir
  i = (rand()*1000000000000.0).to_i
  res = "#{CheckPoint.root}/tmp/#{i}"
  ec "mkdir #{res}", silent: true
  res
end

def git_cmd(cmd, ops)
  raise "bad" unless ops[:working_dir] && ops[:repo]
  ec "git --git-dir=#{ops[:repo]} --work-tree=#{root} #{cmd}", silent: true
end

class MakeDir
  include FromHash

  def initialize(ops={})
    from_hash(ops)
    git_cmd :init, repo: repo, working_dir: root
  end

  fattr(:root) do
    make_temp_dir
  end

  fattr(:repo) do
    res = "#{root}/.gitcp"
    ec "mkdir #{res}", silent: true
    res
  end

  def git(cmd)
    git_cmd cmd, repo: repo, working_dir: root
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

shared_context "make dir" do
  let(:d) do
    MakeDir.new
  end

  def assert_status(ops)
    all = [:changed, :deleted, :added, :untracked]
    other = all - ops.keys
    ops.each do |k,v|
      if k == :other
        other.each do |other_key|
          d.git_obj.status.send(other_key).size.should == v
        end
      else
        d.git_obj.status.send(k).size.should == v
      end
    end
  end

  def read_file(f)
    File.read("#{d.root}/#{f}")
  end

  def assert_file(f,body)
    read_file(f).should == body
  end

  def files
    Dir["#{d.root}/*"]
  end

  let(:track) do
    CheckPoint::Track.new(working_dir: d.root)
  end

end

describe "CheckPoint" do
  include_context "make dir"

  before do
    d.file "a.txt","abc"
    assert_file "a.txt", "abc"
    assert_status changed: 0, deleted: 0
  end

  it 'make dir' do
    d.file "a.txt","xyz", commit: false
    assert_status changed: 1, other: 0
  end

  it 'checkout smoke' do
    d.git "checkout -b m2"
    d.file "b.txt","def"
    files.size.should == 2

    d.git "checkout master"
    files.size.should == 1
  end

  it 'thing' do
    d.git "checkout -b m2"
    d.file "b.txt","def"

    tmp = make_temp_dir
    git = Git.open(tmp, repository: d.repo, index: "#{d.repo}/index")
    git.reset_hard
    git.checkout(:master)
    
    Dir["#{d.root}/*"].size.should == 2
    Dir["#{tmp}/*"].size.should == 1
  end

  it 'track' do
    d.file "b.txt", "def", commit: false
    track.commit!
  end

  it 'track2' do
    track.commit!
    d.file "b.txt", "def", commit: false

    track.commit!
    track.commit!

    # ec "git --work-tree=#{track.working_dir} --git-dir=#{track.repo_dir} log"

    # track.repo.gcommit('master')
    track.repo.diff("master","master^").size.should == 1
  end
end
