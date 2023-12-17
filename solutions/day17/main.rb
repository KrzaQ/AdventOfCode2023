#!/usr/bin/ruby

require 'set'

DATA = File.read('data.txt').lines.map(&:strip).map{ _1.chars.map(&:to_i) }

def next_steps point, direction, steps, data
    y, x = point
    around = []
    case direction
    when :any
        around = [[[y, x - 1], :left, 0], [[y, x + 1], :right, 0],
            [[y - 1, x], :up, 0], [[y + 1, x], :down, 0]]
    when :up
        around = [[[y, x - 1], :left, 0], [[y, x + 1], :right, 0]]
        around << [[y - 1, x], :up, steps + 1] if steps < 2
    when :down
        around = [[[y, x - 1], :left, 0], [[y, x + 1], :right, 0]]
        around << [[y + 1, x], :down, steps + 1] if steps < 2
    when :left
        around = [[[y - 1, x], :up, 0], [[y + 1, x], :down, 0]]
        around << [[y, x - 1], :left, steps + 1] if steps < 2
    when :right
        around = [[[y - 1, x], :up, 0], [[y + 1, x], :down, 0]]
        around << [[y, x + 1], :right, steps + 1] if steps < 2
    end
    around.select do |(y, x), d, s|
        y >= 0 && x >= 0 && y < data.length && x < data[0].length
    end
end

def next_steps_p2 point, direction, steps, data
    y, x = point
    around = []
    case direction
    when :any
        around = [[[y, x - 1], :left, 0], [[y, x + 1], :right, 0],
            [[y - 1, x], :up, 0], [[y + 1, x], :down, 0]]
    when :up
        around = [[[y, x - 1], :left, 0], [[y, x + 1], :right, 0]] if steps > 2
        around << [[y - 1, x], :up, steps + 1] if steps < 9
    when :down
        around = [[[y, x - 1], :left, 0], [[y, x + 1], :right, 0]] if steps > 2
        around << [[y + 1, x], :down, steps + 1] if steps < 9
    when :left
        around = [[[y - 1, x], :up, 0], [[y + 1, x], :down, 0]] if steps > 2
        around << [[y, x - 1], :left, steps + 1] if steps < 9
    when :right
        around = [[[y - 1, x], :up, 0], [[y + 1, x], :down, 0]] if steps > 2
        around << [[y, x + 1], :right, steps + 1] if steps < 9
    end
    around.select do |(y, x), d, s|
        y >= 0 && x >= 0 && y < data.length && x < data[0].length
    end
end

class DijkstraNode
    include Comparable
    attr_accessor :value

    def initialize value, distances
        @value = value
        @distances = distances
    end

    def <=> other
        r = @distances[@value] <=> @distances[other.value]
        r = @value <=> other.value if r == 0
        r
    end
end


def dijkstra start, data, next_nodes_method = :next_steps
    distances = { [start, :any, 0] => 0 }
    queue = SortedSet.new([DijkstraNode.new([start, :any, 0], distances)])

    until queue.empty?
        u = queue.first
        queue.delete u
        point, direction, steps = u.value
        next_nodes = send next_nodes_method, point, direction, steps, data
        next_nodes.each do |v|
            point, direction, steps = v
            alt = distances[u.value] + data.dig(*point)
            if !distances.has_key?(v) || alt < distances[v]
                distances[v] = alt
                queue << DijkstraNode.new(v, distances)
            end
        end
    end
    distances
end

def part1
    dijkstra([0, 0], DATA).select do |k, v|
        y, x = k[0]
        x == DATA[0].length - 1 && y == DATA.length - 1
    end.map{ |k, v| v }.min
end

def part2
    dijkstra([0, 0], DATA, :next_steps_p2).select do |k, v|
        y, x = k[0]
        x == DATA[0].length - 1 && y == DATA.length - 1 && k[2] >= 3
    end.map{ |k, v| v }.min
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
