#!/usr/bin/ruby

M = {
    'one' => ?1,
    'two' => ?2,
    'three' => ?3,
    'four' => ?4,
    'five' => ?5,
    'six' => ?6,
    'seven' => ?7,
    'eight' => ?8,
    'nine' => ?9,
}

def to_ii str
    (M[str] || str).to_i
end

def line_scan str
    (0...(str.length)).map do |i|
        str[i..].scan(/^(one|two|three|four|five|six|seven|eight|nine|\d)/)
            .flatten.map{ |x| to_ii x }
    end.flatten
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
