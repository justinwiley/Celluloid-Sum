class Summer
  include Celluloid
  
  def sum(values)
    @results = values.inject(0){|sum,i| sum += i}
  end
  
  def results
    @results
  end
end