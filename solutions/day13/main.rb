#!/usr/bin/ruby

DATA = File.read('data.txt').split("\n\n").map{ _1.lines.map(&:strip) }

def pattern_symmetry_at_idx pattern, row
    if row + 1 > pattern.size / 2
        len = pattern.size - row - 1
        row if pattern[row-len+1..row] == pattern[row+1..row+len].reverse
    else
        len = row
        row if pattern[0..len] == pattern[row+1..row+len+1].reverse
    end
end

def pattern_symmetry pattern, ignore_pattern = Float::INFINITY
    rows = pattern.each_cons(2).map.with_index.filter_map do |(a, b), idx|
        if a == b and ignore_pattern != idx.succ
            idx
        else
            nil
        end
    end.select do |idx|
        pattern_symmetry_at_idx pattern, idx
    end
    return nil unless rows.size == 1
    rows.first
end

def pattern_value pattern, ignore_pattern = Float::INFINITY
    row = pattern_symmetry pattern, ignore_pattern/100
    return 100 * row.succ if row and ignore_pattern != 100 * row.succ
    col = pattern_symmetry pattern.transpose, ignore_pattern
    col.succ if col and ignore_pattern != col.succ
end

def all_values_with_one_bit_flipped pattern
    pattern.size.times.map do |y|
        pattern[0].size.times.map do |x|
            new_pattern = pattern.map{ _1.join.chars }
            new_pattern[y][x] = new_pattern[y][x] == ?# ? ?. : ?#
            new_pattern
        end
    end.flatten(1)
end

def pattern_value_p2 pattern
    vals = all_values_with_one_bit_flipped(pattern)
    old_pval = pattern_value pattern
    pvals = vals.map do |pattern|
        pattern_value pattern, old_pval
    end.select(&:itself)
    pvals.find{ _1 != old_pval }
end

PART1 = DATA.map { pattern_value _1.map(&:chars) }.sum
PART2 = DATA.map { pattern_value_p2 _1.map(&:chars) }.sum

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
