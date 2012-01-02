# Celluloid Sum

A low-brow project to explore [Celluloid](https://github.com/tarcieri/celluloid), in the simplest context I could imagine: summing a multi-dimensional array.

## Problem: Given an n * n array, sum each sub-array, return the result

### Approach 1: Sequential Inject Approach:

Define array, iterate through each sub-array, sum, return results

    jruby-1.6.5 :006 > set = (1..10).map{ (1..10).to_a }
     => [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], ... [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]] 
    jruby-1.6.5 :007 > res = set.map{|sub_array| sub_array.inject(0){|sum,i| sum+=i} }
     => [55, 55, 55, 55, 55, 55, 55, 55, 55, 55]

### Approach 2: Create Celluloid actors, ask them to sum, gather results

Define a sum-calculating actor that accepts an array, sums via same mechanism as above, stores results for retrieval by accessor.

    class Summer
      include Celluloid

      def sum(values)
        @results = values.inject(0){|sum,i| sum += i}
      end

      def results
        @results
      end
    end

Define a class to distribute an individual array to a given summer
    
    class SumLord
      def self.distribute(marray)
        marray.map do |sub_array|
          yield sub_array
        end
      end
    end

Create set, iterate, creating a summer, asking it to sum.  Call results function on each summer.

    set = (1..10).map{ (1..10).to_a }
    summers = SumLord.distribute(set) do |sub_array|
      Summer.new.tap do |summer|
        summer.sum! sub_array
      end
    end
    summers.map{|s| s.results }

This includes the cost of actor initialization and tear-down.

### Approach 3: Create Celluloid actors, Start benchmarking, ask them to sum, gather results

    set = (1..10).map{ (1..10).to_a }
    summers = initialize_summers(set)
    SumLord.distribute_to_existing_summers(summers,set).map{|summer| summer.results}.uniq.should == [55]

### Benchmarks

    ~cell-sum$ ruby -v
    jruby 1.6.5 (ruby-1.9.2-p136) (2011-10-25 9dcd388) (Java HotSpot(TM) 64-Bit Server VM 1.6.0_29) [darwin-x86_64-java]

    ~/cell-sum$ rspec spec/sum_lord_spec.rb

    Small set: 10 x 10

    Large set: 100 x 100
    .....
    Standard ruby iterative sum: small set
      0.002000   0.000000   0.002000 (  0.002000)
    .
    Standard ruby iterative sum: large set
      0.187000   0.000000   0.187000 (  0.188000)
    .
    Celluloid-based: small set
      0.065000   0.000000   0.065000 (  0.065000)
    .
    Celluloid-based: large set
      0.311000   0.000000   0.311000 (  0.311000)
    .
    Celluloid-based (pre-initialized actors): small set
      0.006000   0.000000   0.006000 (  0.006000)
    .
    Celluloid-based (pre-initialized actors): large set
      0.094000   0.000000   0.094000 (  0.094000)
    ....

    Finished in 1.15 seconds
    14 examples, 0 failures

Iterative sum for large set time: 0.205000
Celluloid-based (pre-initialized actors) sum for large set time: 0.141000

    jruby-1.6.5 :019 > (0.187000 - 0.094000) / 0.187000 * 100
     => 49.73262032085562


