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
  
  def menu_item(name, opts = {})
    if opts[:controller] == controller.controller_name
      render :partial => 'shared/active_menu_item', :locals => { :name => name, :url => url_for(opts) }
    else
      render :partial => 'shared/menu_item', :locals => { :name => name, :url => url_for(opts) }
    end
  end

  def link_to_protected(title, protect, *args)
    permission = protect[:require]
    if require_permission(permission, protect)
      return link_to(title, *args)
    else
      return title
    end
  end
  
  def paginate(obj)
    will_paginate obj, :previous_label => t('pagination.back'),
      :prev_label => t('pagination.back'), :next_label => t('pagination.next')
  end
end

# FIXME: dunno where is the right place to put this
class Fixnum
  def format_h
    # TODO: fix this when we store minutes, not hours in database
    to_s + ':00'
  end
end
