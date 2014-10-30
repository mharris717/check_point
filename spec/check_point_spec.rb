

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CheckPoint" do
  it 'smoke' do
    2.should == 2
    CheckPoint.should be
  end
end
