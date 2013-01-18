#!/usr/bin/env ruby

require 'json'

data = JSON.parse(IO.read(ARGV[0]))
puts data
