require 'rubygems'
require 'bundler/setup'
require 'benchmark'
require 'celluloid'
require 'summer'
require 'sum_lord'

Dir['./spec/support/*.rb'].map {|f| require f }
