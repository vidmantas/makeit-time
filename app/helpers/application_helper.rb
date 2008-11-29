# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { " Timetrack | #{page_title}" }
  end
  
  # TODO
  # - add restful_authentication 
  def current_user
    Employee.first
  end
  
  def calendar(input_field, format = "%Y-%m-%d")
    javascript_tag <<-CODE
      Calendar.setup({
        inputField : "#{input_field}",
        ifFormat : "#{format}"
      });
    CODE
  end
end
