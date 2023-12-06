#!/usr/bin/ruby

DATA = File.read('data.txt').lines
TS, DS = DATA.map{ _1.scan(/\d+/).map(&:to_i) }
RACES = [TS, DS].transpose

def comp_one record, dist
    0.upto(record).map{ (record - _1) * _1 }.select{ _1 > dist }.count
end

PART1 = RACES.map{ comp_one *_1 }.inject(:*)
PART2 = comp_one TS.join.to_i, DS.join.to_i

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
