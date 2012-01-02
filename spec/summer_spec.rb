require 'spec_helper'

describe Summer do
  let(:summer){ Summer.new }
  let(:vals){ [0,1,2,3,4] }
  
  context 'Setters and Getters' do
    it '#sum should accept an array of variables, and return the resulting sum' do
      summer.sum(vals).should == 10
    end
  
    it '#results should return results from last sum' do
      summer.sum(vals)
      summer.results.should == 10
    end
  
    it '#sum! should asyncronouslly calculate sum, store, return results via accessor when called' do
      summer.sum!(vals).should == nil
      summer.results.should == 10
    end
  end
end