#!/usr/bin/ruby

require 'set'

DATA = File.read('data.txt').lines.map{ _1.strip.chars }

S = DATA.find_index{ _1.include? ?S }
    .yield_self{ [_1, DATA[_1].find_index(?S)] }

def exists? y, x, data = DATA
    y < data.size && x < data[y].size && y >= 0 && x >= 0
end

def around y, x, data = DATA
    c = data.dig(y, x)
    case c
    when ?|
        [[y-1, x], [y+1, x]]
    when ?-
        [[y, x-1], [y, x+1]]
    when ?L
        [[y-1, x], [y, x+1]]
    when ?J
        [[y-1, x], [y, x-1]]
    when ?7
        [[y+1, x], [y, x-1]]
    when ?F
        [[y+1, x], [y, x+1]]
    when ?.
        []
    when ?,
        []
    when ?S
        [[y+1, x], [y, x+1], [y-1, x], [y, x-1]]
            .select{ |y, x| exists? y, x, data }
            .reject{ |y, x| %w(,.).include? data.dig(y, x) }
            .select{ |yy, xx| around(yy, xx, data).include? [y, x] }
    else
        raise "Unknown character: #{c}, #{y}, #{x}"
    end.select{ |y, x| exists? y, x, data }
end

def dijkstra data, start
    q = [start].to_set
    d = { start => 0 }
    until q.empty?
        u = q.min_by{ d[_1] }
        q.delete u
        around(u[0], u[1], data).each do |v|
            alt = d[u] + 1
            if !d.has_key?(v) || alt < d[v]
                d[v] = alt
                q << v
            end
        end
    end
    d
end

def print_map data, main_loop = nil
    data.each_with_index do |row, y|
        row.each_with_index do |col, x|
            if main_loop and main_loop.has_key? [y, x]
                print '*'
                next
            end
            print case col
            when ?|
                '│'
            when ?-
                '─'
            when ?L
                '└'
            when ?J
                '┘'
            when ?7
                '┐'
            when ?F
                '┌'
            when ?S
                '╳'
            when ?.
                '.'
            when ?,
                ','
            when ' '
                ' '
            when ?@
                '@'
            else
                raise "Unknown character: <#{col}>"
            end
        end
        puts
    end
end

def sparsify data
    new_data = (data.size * 2 - 1).times.map do
        ([' '] * (data.first.size * 2 - 1)).flatten
    end
    data.each_with_index do |row, y|
        row.each_with_index do |col, x|
            new_data[y*2][x*2] = col
        end
    end
    new_data.each_with_index do |row, y|
        row.each_with_index do |col, x|
            next if x % 2 == 0 and y % 2 == 0
            up = new_data.dig(y-1, x)
            left = new_data.dig(y, x-1)
            right = new_data.dig(y, x+1)
            down = new_data.dig(y+1, x)
            if %w(| 7 F S).include?(up) and %w(| J L S).include?(down)
                new_data[y][x] = ?|
            elsif %w(- L F S).include?(left) and %w(- 7 J S).include?(right)
                new_data[y][x] = ?-
            else
                new_data[y][x] = ?,
            end
        end
    end
    new_data
end

def around_xy y, x, data
    [[y-1, x], [y, x+1], [y+1, x], [y, x-1]].reject do |y, x|
        x < 0 || y < 0 || y >= data.size || x >= data[y].size
    end.select do |y, x|
        ['.', ',', ' '].include? data[y][x]
    end
end

SPARSE = sparsify(DATA)

def dijkstra_p2 data, start
    q = [start].to_set
    d = { start => 0 }
    until q.empty?
        u = q.min_by{ d[_1] }
        q.delete u
        around_xy(*u, data)
        around_xy(*u, data).each do |v|
            alt = d[u] + 1
            if !d.has_key?(v) || alt < d[v]
                d[v] = alt
                q << v
            end
        end
    end
    d
end

S2 = SPARSE.find_index{ _1.include? ?S }
    .yield_self{ [_1, SPARSE[_1].find_index(?S)] }

MAIN_LOOP_P2 = dijkstra SPARSE, S2
SPARSE.each_with_index do |row, y|
    row.each_with_index do |col, x|
        next if y % 2 == 1 or x % 2 == 1
        SPARSE[y][x] = ?. unless MAIN_LOOP_P2.has_key? [y, x]
    end
end

DOTS = SPARSE.map.with_index do |row, y|
    row.map.with_index.select do |col, x|
        col == ?.
    end.map{ |col, x| [y, x] }
end.flatten(1)

print_map SPARSE

PART1 = dijkstra(DATA, S).values.max
def part2
    todo = DOTS.to_set
    found = Set.new
    while todo.size > 0
        points = dijkstra_p2 SPARSE, todo.first
        border = points.keys.find{ |y, x| x == 0 or y == 0 or x == SPARSE.first.size - 1 or y == SPARSE.size - 1 }
        if not border
            to_remove = points.keys.select{ |y, x| SPARSE[y][x] == ?. }
            to_remove.each do |y, x|
                found << [y, x]
                todo.delete [y, x]
            end
        else
            points.keys.each{ |yx| todo.delete yx }
        end
    end
    found.size
end

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % part2
