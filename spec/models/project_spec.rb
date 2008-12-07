require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  fixtures :all
  
  before(:each) do
    @new_project = Project.new(
      :manager    => employees(:jonas),
      :code       => 'test',
      :name       => 'Test project',
      :start_date => Time.parse('2005-05-10').to_date,
      :end_date   => Time.now.to_date
    )
  end
  
  it "should set 5 month duration for 2005-05-10 -- 2005-10-01 project" do
    @new_project.end_date = Time.parse('2005-10-01').to_date
    @new_project.save
    @new_project.duration.should == 5
  end
  
  it "should set 11 months duration for 2005-05-10 -- 2006-03-31" do
    @new_project.end_date = Time.parse('2006-03-31').to_date
    @new_project.save
    @new_project.duration.should == 11
  end
  
  it "should set 24 months duration for 2005-05-10 -- 2007-04-10" do
    @new_project.end_date = Time.parse('2007-04-10').to_date
    @new_project.save
    @new_project.duration.should == 24
  end
  
  it "should return 16 for MIF project value" do
    projects(:mif).total_value.should == 16
  end
end