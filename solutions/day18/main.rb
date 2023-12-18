#!/usr/bin/ruby

DATA = File.read('data.txt').scan(/(\w) (\d+) \(#([\d\w]{6})\)/)

def dir_to_xy x, y, dir, steps
    {
        ?U => [x, y - steps],
        ?R => [x + steps, y],
        ?D => [x, y + steps],
        ?L => [x - steps, y],
    }[dir]
end

POINTS_P1 = DATA.inject([[0,1]]) do |path, (dir, steps, color)|
    steps = steps.to_i
    color = color.to_i(16)
    x, y = path.last
    path << dir_to_xy(x, y, dir, steps)
end

POINTS_P2 = DATA.inject([[0,1]]) do |path, (dir, steps, color)|
    x, y = path.last
    steps = color[0...5].to_i(16)
    dir = %w(R D L U)[color[5].to_i(16) % 4]
    path << dir_to_xy(x, y, dir, steps)
end

def area pts
    shoelace = pts.each_cons(2).map do |(x1, y1), (x2, y2)|
        x1 * y2 - x2 * y1
    end.sum / 2

    perimeter = pts.each_cons(2).map do |(x1, y1), (x2, y2)|
        (x2 - x1 + y2 - y1).abs
    end.sum
    shoelace + perimeter / 2 + 1
end

puts 'Part 1: %s' % area(POINTS_P1)
puts 'Part 2: %s' % area(POINTS_P2)
