#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map{ _1.scan(/-?\d+/).map(&:to_i) }

def extrapolate_line line, order, op
    lines = [line]
    until lines.last.all?(0) do
        lines << lines.last.each_cons(2).map{ _2 - _1 }
    end
    lines.reverse.inject(0){ |obj, l| l.send(order).send(op, obj) }
end

PART1 = DATA.map{ extrapolate_line _1, :last, :+ }.sum
PART2 = DATA.map{ extrapolate_line _1, :first, :- }.sum

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
