require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sector do
  fixtures :all  
  
  it "first_sector should have two employees" do
    sectors(:first).employees.size.should == 2
  end
  
  it "should return manager sector first for sector report" do
    projects(:achema).sectors.first.id.should == sectors(:first).id
  end
  
  it "should return two sectors for sector report" do 
    projects(:achema).sectors.size.should == 2
  end
  
  it "should include Teo project" do
    sectors(:second).has_projects('2007-01-01', '2007-03-31').include?(projects(:teo)).should be_true
  end
  
  it "should include Mif project" do
    sectors(:second).has_projects('2007-01-01', '2007-03-31').include?(projects(:mif)).should be_true
  end
  
  it "should have 2 projects" do
    sectors(:second).has_projects('2007-01-01', '2007-03-31').size.should == 2
  end
end

describe Sector, "in time usage report" do
  fixtures :all
  
  it "should sum 155 total hours for '2007-01-01 -- 2007-03-31' period" do
    sectors(:first).time_usage_for('2007-01-01', '2007-03-31').to_i.should == 155
  end
  
  it "should return 130*2*3=780 theoretical hours for '2007-01-01 -- 2007-03-31' period" do
    sectors(:first).theoretical_hours('2007-01-01', '2007-03-31').should == 130*3*2
    # two employees in this sector
  end
  
  it "should return 12 hours overtime for '2007-01-01 -- 2007-03-31' period" do
    sectors(:first).overtime('2007-01-01', '2007-03-31').to_i.should == 12
  end
  
  it "should return 80% for inactivity percent for '2007-01-01 -- 2007-03-31' period" do
    sectors(:first).inactivity_percent('2007-01-01', '2007-03-31').should == 80
  end
  
  it "should return 2% for ivertime percent for '2007-01-01 -- 2007-03-31' period" do
    sectors(:first).overtime_percent('2007-01-01', '2007-03-31').should == 2
  end 
end

describe Sector, "in switching report" do
  fixtures :all
  
  it "should return 1 as total switches for '2007-01-01 -- 2007-12-31' period" do
    sectors(:second).total_switches('2007-01-01', '2007-12-31').should == 1
  end
  
  it "should return 28 total hours for '2007-01-01 -- 2007-12-31' period" do
    sectors(:second).time_usage_for('2007-01-01', '2007-12-31').to_i.should == 28
  end
  
  it "should return 2 as total switches for '2008-01-01 -- 2008-12-31' period" do
    sectors(:second).total_switches('2008-01-01', '2008-12-31').should == 2
  end
  
  it "should return 14 total hours for '2008-01-01 -- 2008-12-31' period" do
    sectors(:second).time_usage_for('2008-01-01', '2008-12-31').to_i.should == 14
  end
  
  it "should return 142.86 as switches for 1000 hours for '2008-01-01 -- 2008-12-31' period" do
    sectors(:second).switches_for_hours('2008-01-01', '2008-12-31').should == "142.86"
  end
end

describe Sector, "in progress report" do
  fixtures :all
  # time usage is already tested
  
  it "should return income 25 for '2007-01-01 -- 2007-03-31' period" do
    sectors(:first).income_for_short_projects('2007-01-01', '2007-03-31').to_i.should == 25
  end
  
  it "should return income 0 for '2007-01-01 -- 2007-03-31' period" do
    sectors(:second).income_for_short_projects('2007-01-01', '2007-03-31').to_i.should == 0
  end
  
  it "should return income 0 for '2005-01-01 -- 2005-03-31' period" do
    # because first payment is due 2005-07-01
    sectors(:first).income_for_medium_projects('2005-01-01', '2005-03-31').to_i.should == 0
  end
  
  it "should return income 20 for '2005-04-01 -- 2005-07-31' period" do
    # because first payment is due 2005-07-01
    sectors(:first).income_for_medium_projects('2005-04-01', '2005-07-31').to_i.should == 20
  end
  
  it "should return income 30 for '2005-10-01 -- 2005-12-31' period" do
    # because second payment is due project end
    sectors(:first).income_for_medium_projects('2005-10-01', '2005-12-31').to_i.should == 30
  end
  
  it "should return 3.2 income for '2007-04-01 -- 2007-06-30' period" do
    sectors(:second).income_for_long_projects('2007-04-01','2007-06-30').to_f.should == 3.2
  end
  
  it "should return 3.2 income for '2007-10-01 -- 2007-12-31' period" do
    sectors(:second).income_for_long_projects('2007-10-01', '2007-12-31').to_f.should == 3.2
  end
  
  it "should return 9.6 income for '2008-07-01 -- 2008-09-30' period" do
    sectors(:second).income_for_long_projects('2008-07-01', '2008-09-30').to_f.should == 9.6
  end
  
  it "should return 50 income for '2005-01-01 -- 2005-12-31' period" do
    sectors(:first).income('2005-01-01', '2005-12-31').to_i.should == 50
  end
  
  it "should return 163.4 income for '2007-01-01 -- 2007-12-31' period" do
    sectors(:second).income('2007-01-01', '2007-12-31').should == 163.4
  end
end
