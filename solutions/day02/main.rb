#!/usr/bin/ruby

def parse_game(game)
    num, vals = *game.split(?:)
    vals = vals.scan(/(\d+) (\w+)/)
        .group_by{ |v, k| k }
        .map{ |k, a| [k.to_sym, a.map{ |v, _| v.to_i }.max] }
        .to_h
        .merge(id: num.scan(/\d+/).first.to_i)
end

def power game
    game[:red] * game[:green] * game[:blue]
end

DATA = File.read('data.txt')
    .lines
    .map{ |l| parse_game(l) }

PART1 = DATA
    .select{ |g| g[:red] <= 12 and g[:green] <= 13 and g[:blue] <= 14 }
    .map{ |g| g[:id] }.sum

PART2 = DATA.map{ |g| power(g) }.sum

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
