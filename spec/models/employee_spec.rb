require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Employee do
  fixtures :all
  
  it "should be marked as project manager if has any projects" do
    employees(:jonas).is_project_manager.should be_true
  end
  
  it "should not be marked as project manager if he's just a developer" do
    employees(:dede_sigitas).is_project_manager.should be_false
  end
end