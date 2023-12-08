#!/usr/bin/ruby

DATA = File.read('data.txt').lines

INSTRUCTIONS = DATA.first.strip
PATH = DATA[2..-1].map{ a,b,c = _1.scan(/[\w\d]{3}/); [a, [b, c]] }.to_h

def walk_path x, rx = /^ZZZ$/
    (0..).each do |i|
        lr = INSTRUCTIONS[i % INSTRUCTIONS.size]
        x = if lr == ?L
            PATH[x][0]
        elsif lr == ?R
            PATH[x][1]
        end
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
