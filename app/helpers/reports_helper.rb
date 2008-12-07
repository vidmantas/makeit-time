module ReportsHelper
  def currency(num)
    number_to_currency num, :unit => " ", :separator => ",", :delimiter => " "
  end
end
