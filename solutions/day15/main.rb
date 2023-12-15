#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map(&:strip).first.split(?,)

def hash str
    str.chars.inject(0){ |h, c| (h + c.ord) * 17 % 256 }
end

PART1 = DATA.map{ hash _1 }.sum

def part2
    DATA.inject({}) do |m, s|
        if s =~ /(\w+)-/
            next m unless m[hash($1)]
            idx = m[hash($1)].find_index{ _1[0] == $1 }
            m[hash($1)].delete_at idx if idx
        elsif s =~ /(\w+)=(\d+)/
            m[hash($1)] ||= []
            idx = m[hash($1)].find_index{ _1[0] == $1 }
            m[hash($1)][idx][1] = $2.to_i if idx
            m[hash($1)] << [$1, $2.to_i] unless idx
        end
        m
    end.map do |k, v|
        v.map.with_index{ |(_, vv), i| k.succ * vv * i.succ }.sum
    end.sum
end

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % part2
