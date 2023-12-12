#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map{ _1.strip.chars }

INDICES = DATA.map.with_index do |row, y|
    row.map.with_index.select do |col, x|
        col == ?#
    end.map do |_, x|
        [y, x]
    end
end.flatten(1)

DOUBLE_COLS = DATA[0].size.times.reject do |x|
    INDICES.find { |a| a[1] == x }
end

DOUBLE_ROWS = DATA.size.times.reject do |y|
    INDICES.find { |a| a[0] == y }
end

def distance a, b, multiplier = 1
    y1, x1 = a
    y2, x2 = b
    ymin, ymax = [y1, y2].minmax
    xmin, xmax = [x1, x2].minmax
    doubled_cols = DOUBLE_COLS.count{ |x| x < xmax && x > xmin } * multiplier
    doubled_rows = DOUBLE_ROWS.count{ |y| y < ymax && y > ymin } * multiplier
    (y2 - y1).abs + (x2 - x1).abs + doubled_cols + doubled_rows
end

def sum_paths distance_multiplier = 1
    INDICES.size.times.map do |i|
        cur = INDICES[i]
        INDICES[i+1..].map{ distance cur, _1, distance_multiplier }.sum
    end.sum
end

puts 'Part 1: %s' % sum_paths(1)
puts 'Part 2: %s' % sum_paths(999999)
