#!/usr/bin/ruby

DATA = File.read('data.txt').lines
INSTRUCTIONS = DATA.first.strip
PATH = DATA[2..-1].map{ a,b,c = _1.scan(/[\w\d]{3}/); [a, [b, c]] }.to_h

def walk_path x, rx = /^ZZZ$/
    (0..).each do |i|
        x = PATH[x][INSTRUCTIONS[i % INSTRUCTIONS.size] == ?L ? 0 : 1]
        return i.succ if x =~ rx
    end
end

PART1 = walk_path 'AAA'
PART2 = PATH.keys
    .select{ _1 =~ /..A/ }
    .map{ walk_path _1, /^..Z$/ }
    .inject(&:lcm)

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
