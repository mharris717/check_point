require 'git'

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MakeDir
  include FromHash

  fattr(:root) do
    i = (rand()*1000000000000.0).to_i
    res = "#{CheckPoint.root}/tmp/#{i}"
    ec "mkdir #{res}", silent: true
    ec "git --git-dir=#{repo} --work-tree=#{res} init", silent: true
    res
  end

  fattr(:repo) do
    i = (rand()*1000000000000.0).to_i
    res = "#{CheckPoint.root}/tmp/#{i}"
    ec "mkdir #{res}", silent: true
    #res = "#{res}/.git"
    #ec "mkdir #{res}", silent: true
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

    puts 
  end
end
