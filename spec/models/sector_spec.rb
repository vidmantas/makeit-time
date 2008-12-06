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
