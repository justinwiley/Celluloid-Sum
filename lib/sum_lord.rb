class SumLord
  def self.distribute(marray)
    marray.map do |sub_array|
      yield sub_array
    end
  end
  
  def self.distribute_to_existing_summers(summers,marray)
    marray.each_with_index do |sub_array,i|
      summers[i].sum! sub_array
    end
    summers
  end
  
end