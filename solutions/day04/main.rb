#!/usr/bin/ruby

def parse_card line
    card, their, my = line.split(/[:|]/)
    card = card.scan(/\d+/).first.to_i
    their = their.scan(/\d+/).map(&:to_i)
    my = my.scan(/\d+/).map(&:to_i)
    {
        id: card,
        my: my,
        their: their
    }
end

def points card
    match = card[:my] & card[:their]
    match.count > 0 ? 2 ** (match.count - 1) : 0
end

DATA = File.read('data.txt')
    .lines
    .map { |line| parse_card line }

PART1 = DATA.map{ |card| points card }.sum

def part2
    (1..DATA.count).each_with_object([1] * DATA.count) do |i, acc|
        card = DATA[i - 1]
        match = (card[:my] & card[:their]).count
        my_count = acc[i-1]
        ((i+1)..(i+match)).each do |j|
            acc[j-1] += my_count
        end
    end.sum
end

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % part2
