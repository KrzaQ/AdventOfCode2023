#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map do |line|
    a, b = line.split
    [a, b.to_i]
end
ORDER_P1 = %w(A K Q J T 9 8 7 6 5 4 3 2)
ORDER_P2 = %w(A K Q T 9 8 7 6 5 4 3 2 J)

def hand_strength hand
    case hand.chars.sort.group_by(&:itself).map{ _2.count }.sort
    when [1, 1, 1, 1, 1]
        1
    when [1, 1, 1, 2]
        2
    when [1, 2, 2]
        3
    when [1, 1, 3]
        4
    when [2, 3]
        5
    when [1, 4]
        6
    when [5]
        7
    end
end


def hand_strength_p2 hand
    ORDER_P2.map{ hand_strength hand.gsub(?J, _1) }.max
end

def compare_hands a, b, mode = :part1
    aa, bb, order = if mode == :part1
        [a, b].map{ hand_strength _1 } << ORDER_P1
    else
        [a, b].map{ hand_strength_p2 _1 } << ORDER_P2
    end
    if aa == bb
        [b, a].map{ _1.chars.map{ |el| order.index el } }.inject(:<=>)
    else
        aa <=> bb
    end
end

def compute part
    DATA.sort do |a, b|
        compare_hands a[0], b[0], part
    end.map.with_index do |el, i|
        hand, score = el
        score * (i + 1)
    end.sum
end

puts 'Part 1: %s' % compute(:part1)
puts 'Part 2: %s' % compute(:part2)
