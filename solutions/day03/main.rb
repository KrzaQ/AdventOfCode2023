#!/usr/bin/ruby

LINES = File.read('data.txt')
    .lines

WITH_OFFSETS = LINES.each_with_index.map do |line, idx|
    r = []
    line.scan(/\d+/) do |n|
        r << [n.to_i, idx, $~.offset(0)[0]]
    end
    r
end.flatten(1)

CHARS = LINES.map(&:strip).map(&:chars)

def points_around x, y
    r = []
    [-1, 0, 1].product([-1, 0, 1]).each do |dx, dy|
        fx = x + dx
        fy = y + dy
        next if dx == 0 and dy == 0
        next if fx < 0 or fy < 0
        next if fx >= CHARS[y].count or fy >= CHARS.count
        r << [fx, fy]
    end
    r
end

PART2 = WITH_OFFSETS.map do |n, y, x|
    gears = []
    (x...(x + n.to_s.length)).each do |xx|
        points_around(xx, y).each do |px, py|
            next if py == y and px >= x and px < x + n.to_s.length
            gears << [px, py] if CHARS[py][px] == ?*
        end
    end
    [n, y, x, gears.uniq]
end.select do |n, y, x, gears|
    gears.count > 0
end.group_by(&:last).select do |k, v|
    v.count == 2
end.map do |k, v|
    v.map(&:first).inject(:*)
end.sum

PART1 = WITH_OFFSETS.select do |n, y, x|
    # p [n, y, x] if n == 48
    (x...(x + n.to_s.length)).any? do |xx|
        points_around(xx, y).any? do |px, py|
            next if py == y and px >= x and px < x + n.to_s.length
            CHARS[py][px] !~ /[0-9\.]/
        end
    end
end.map(&:first).sum

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
