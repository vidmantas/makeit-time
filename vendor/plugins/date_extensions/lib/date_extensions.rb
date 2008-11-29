module DateExtensions
  def each_month_until(end_date)
    current   = self
    while current < (end_date + 1.month) do
      yield(current)
      current += 1.month
    end  
  end
end
