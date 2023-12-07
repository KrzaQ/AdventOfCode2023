#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map(&:split).map{ [_1, _2.to_i] }
ORDER_P1 = %w(A K Q J T 9 8 7 6 5 4 3 2)
ORDER_P2 = %w(A K Q T 9 8 7 6 5 4 3 2 J)

def hand_strength hand
    type = hand.chars.group_by(&:itself).map{ _2.count }.sort.join
    %w(11111 1112 122 113 23 14 5).index type
end

def hand_strength_p2 hand
    ORDER_P2.map{ hand_strength hand.gsub(?J, _1) }.max
end

def compare_hands a, b, mode = :part1
    aa, bb, order = {
        part1: -> { [hand_strength(a),    hand_strength(b),    ORDER_P1] },
        part2: -> { [hand_strength_p2(a), hand_strength_p2(b), ORDER_P2] },
    }[mode][]
    ifsame = -> x { x.map{ _1.chars.map{ |el| order.index el } }.inject(:<=>) }
    aa == bb ? ifsame[[b, a]] : aa <=> bb
end

def compute part
    DATA.sort do |a, b|
        compare_hands a[0], b[0], part
    end.map.with_index do |el, i|
        hand, score = el
        score * i.succ
    end.sum
end

puts 'Part 1: %s' % compute(:part1)
puts 'Part 2: %s' % compute(:part2)
