require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  fixtures :all
  
  it "should not allow to see home without login" do
    get :index
    response.should redirect_to(new_employee_sessions_url)
  end
  
  
  it "should allow to see home for simple employee" do
    login :employee => employees(:teta_liucija)
    get :index
    response.should be_success
    logout
  end
  
  it "should allow to see home for project managers" do
    login :employee => employees(:jonas)
    get :index
    response.should be_success
    logout
  end
  
  it "should redirect vadas to projects" do
    login :employee => employees(:vadas)
    get :index
    response.should redirect_to(projects_url)
    logout
  end
end