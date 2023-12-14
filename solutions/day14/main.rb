#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map(&:strip).map(&:chars)

def tilt data
    tilted = data.map{ |row| row.map(&:dup) }
    tilted.each_with_index do |row, y|
        row.each_with_index do |value, x|
            next unless value == ?O
            last = tilted[0...y].reverse.find_index{ _1[x] != ?. } || y
            tilted[y - last][x] = ?O
            tilted[y][x] = ?. if last != 0
        end
    end
    tilted
end

def count_load data
    data.reverse.map.with_index do |row, y|
        row.map{ _1 == ?O ? y.succ : 0 }.sum
    end.sum
end

def rotate data
    data.transpose.map(&:reverse)
end

def cycle data
    4.times{ data = rotate tilt data }
    data.map{ _1.map(&:dup) }
end

def part2
    d = DATA
    x = {}
    1000000000.times do |i|
        d = cycle d
        if x[d]
            x[d] << i
            diff = x[d][-1] - x[d][-2]
            if (1000000000 - i.succ) % diff == 0
                return count_load(d)
            end
        else
            x[d] = [i]
        end
    end
end

PART1 = count_load tilt DATA

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % part2
