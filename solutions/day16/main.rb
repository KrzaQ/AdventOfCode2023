#!/usr/bin/ruby

require 'set'

DATA = File.read('data.txt').lines.map(&:strip).map(&:chars)

def next_step  y, x, direction, data
    n = case [direction, data.dig(y, x)]
    when [:right, ?-], [:right, ?.]
        [[y, x + 1, :right]]
    when [:right, ?/]
        [[y - 1, x, :up]]
    when [:right, ?\\]
        [[y + 1, x, :down]]
    when [:right, ?|]
        [[y + 1, x, :down], [y - 1, x, :up]]
    when [:up, ?|], [:up, ?.]
        [[y - 1, x, :up]]
    when [:up, ?/]
        [[y, x + 1, :right]]
    when [:up, ?\\]
        [[y, x - 1, :left]]
    when [:up, ?-]
        [[y, x + 1, :right], [y, x - 1, :left]]
    when [:left, ?-], [:left, ?.]
        [[y, x - 1, :left]]
    when [:left, ?/]
        [[y + 1, x, :down]]
    when [:left, ?\\]
        [[y - 1, x, :up]]
    when [:left, ?|]
        [[y + 1, x, :down], [y - 1, x, :up]]
    when [:down, ?|], [:down, ?.]
        [[y + 1, x, :down]]
    when [:down, ?/]
        [[y, x - 1, :left]]
    when [:down, ?\\]
        [[y, x + 1, :right]]
    when [:down, ?-]
        [[y, x + 1, :right], [y, x - 1, :left]]
    end
    # p n
    n
end

def exist? y, x, data
    y >= 0 && y < data.size && x >= 0 && x < data[y].size
end

def print_data data, counts
    data.each_with_index do |row, y|
        row.each_with_index do |c, x|
            if counts[[y, x]]
                # print counts[[y, x]] % 10
                print ?#
            else
                print c
            end
        end
        puts
    end
end

def get_energized start = [0, 0, :right]
    counts = { [start[0], start[1]] => 1 }
    next_steps = [start]
    walked = [start].to_set
    while next_steps.count > 0
        y, x, direction = next_steps.shift
        walked << [y, x, direction]
        new_steps = next_step(y, x, direction, DATA).select do |y, x, _|
            exist? y, x, DATA
        end.reject do |y, x, _|
            # counts[[y, x]]
            walked.include? [y, x, _]
        end
        new_steps.each do |y, x, direction|
            counts[[y, x]] ||= 0
            counts[[y, x]] += 1
        end
        next_steps += new_steps
    end
    counts
end

PART1 = get_energized.size

def part2
    rl = DATA.size.times.map do |y|
        r = [y, 0, :right]
        l = [y, DATA[y].size - 1, :left]
        [r, l]
    end.flatten(1)
    ud = DATA[0].size.times.map do |x|
        u = [0, x, :down]
        d = [DATA.size - 1, x, :up]
        [u, d]
    end.flatten(1)

    (rl + ud).map{ get_energized(_1).size }.max
end

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % part2
