module ReportsHelper
  def currency(num, opts = {})
    options = { :precision => 2, :separator => ',', :delimiter => ' '}.merge(opts)
    number_with_precision num, options
  end
  
  def percentage(num, opts = {})
    if num.is_a?(Float) && (num.nan? || num.infinite?)
      num = 0
    end

    options = { :precision => 2, :separator => ',' }.merge(opts)
    number_to_percentage(num, options)
  end
end
