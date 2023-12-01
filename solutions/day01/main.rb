#!/usr/bin/ruby

M = %w(one two three four five six seven eight nine).zip(?1..?9).to_h

def line_scan str
    str.scan(/(?=(one|two|three|four|five|six|seven|eight|nine|\d))/)
        .flatten
        .map{ (M[_1] || _1).to_i }
end

DATA_ONE = File.read('data.txt')
    .lines
    .map{ _1.scan(/(\d)/).flatten.map(&:to_i) }
    .map{ _1.first * 10 + _1.last }
DATA_TWO = File.read('data.txt')
    .lines
    .map{ line_scan _1 }
    .map{ _1.first * 10 + _1.last }

puts 'Part 1: %s' % DATA_ONE.sum
puts 'Part 2: %s' % DATA_TWO.sum
