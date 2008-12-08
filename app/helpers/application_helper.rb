# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { "MakeIT Timetrack: #{page_title}" }
  end
  
  def calendar(input_field, format = "%Y-%m-%d")
    javascript_tag <<-CODE
      Calendar.setup({
        inputField : "#{input_field}",
        ifFormat : "#{format}"
      });
    CODE
  end
  
  def loader
    render :partial => 'shared/loader'
  end
end

# FIXME: dunno where is the right place to put this
class Fixnum
  def format_h
    # TODO: fix this when we store minutes, not hours in database
    to_s + ':00'
  end
end
