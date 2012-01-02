require 'spec_helper'

describe SumLord do
  def initialize_summers(set)
    (1..set.size).map{ Summer.new }
  end
  
  def gen_set(n)
    (1..n).map{ (1..n).to_a }     # n x n array
  end
  let (:small_set){ gen_set(10) }
  let (:large_set){ gen_set(100) }

  it '#small_set members should sum to 55' do
    small_set.map{|s| s.inject(0){|sum,i| sum+=i}}.uniq.should == [55]
  end

  context 'Distributing sample sets' do
    it '#distribute should accept a multi-deminsional array, distribute to given block' do
      SumLord.distribute(small_set) do |sub_array|
        sub_array.inject(0){|sum,x| sum+=x}
      end.uniq.should == [55]
    end
    
    it '#distribute should work similarly with Summers' do
      summers = SumLord.distribute(small_set) do |sub_array|
        Summer.new.tap do |summer|
          summer.sum! sub_array
        end
      end
      summers.map{|s| s.results }.uniq.should == [55]
    end
    
    it '#distribute_to_existing_summers should accept a set of existing Celluloid summers, distribute an array to each' do
      summers = initialize_summers(small_set)
      SumLord.distribute_to_existing_summers(summers,small_set).map{|summer| summer.results}.uniq.should == [55]
    end
  end
    
  context 'Traditional Iterative Summing' do
    it 'should display benchmarks for small set' do
      puts "\nStandard ruby iterative sum: small set"
      puts Benchmark.measure {
        SumLord.distribute(small_set){|sub_array| sub_array.inject(0){|sum,x| sum+=x} }
      }
    end

    it 'should display benchmarks for large set' do
      puts "\nStandard ruby iterative sum: large set"
      puts Benchmark.measure {
        SumLord.distribute(large_set){|sub_array| sub_array.inject(0){|sum,x| sum+=x} }
      }
    end
  end

  context 'Celloid-Based Concurent Summing' do
    context 'Including object setup and initialization time' do
      def do_sum(set)
        summers = SumLord.distribute(set) do |sub_array|
          Summer.new.tap do |summer|
            summer.sum! sub_array
          end
        end
        summers.map{|s| s.results }
      end
    
      it 'should display benchmarks for small set' do
        puts "\nCelluloid-based: small set"
        results = Benchmark.measure {
          do_sum small_set
        }
        puts results
      end
    
      it 'should display benchmarks for large set' do
        puts "\nCelluloid-based: large set"
        results = Benchmark.measure {
          do_sum large_set
        }
        puts results
      end
    
    end

    context 'Objects preinitialized' do
      it 'should display benchmarks for small set' do
        summers = initialize_summers small_set
        puts "\nCelluloid-based (pre-initialized actors): small set"
        results = Benchmark.measure {
          SumLord.distribute_to_existing_summers(summers,small_set).map{|summer| summer.results}
        }
        puts results
      end

      it 'should display benchmarks for large set' do
        summers = initialize_summers large_set
        puts "\nCelluloid-based (pre-initialized actors): large set"
        results = Benchmark.measure {
          SumLord.distribute_to_existing_summers(summers,large_set).map{|summer| summer.results}
        }
        puts results
      end
    end
  end
  
end
