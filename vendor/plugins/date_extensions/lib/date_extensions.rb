module DateExtensions
  def each_month_until(end_date)
    current   = self
    while current < (end_date + 1.month) do
      yield(current)
      current += 1.month
    end  
  end
  
  def each_year_until(end_date)
    current = self.year
    while current <= (end_date.year) do
      yield(current)
      current += 1
    end
  end
  
  def each_quarter_until(end_date)
    current = self.beginning_of_quarter
    while current <= (end_date.end_of_quarter) do
      yield(current)
      current += 3.months
    end
  end
end
