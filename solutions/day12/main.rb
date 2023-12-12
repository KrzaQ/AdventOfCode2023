#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map{ _1.strip }

SPRINGS = DATA.map do |line|
    springs, nums = line.split
    nums = nums.split(',').map(&:to_i)
    [springs, nums]
end

$mem = {}
def count_options springs, counts
    return $mem[[springs, counts]] if $mem[[springs, counts]]
    springs += ?X unless springs.end_with? ?X
    return springs.count(?#) == 0 ? 1 : 0 if counts.size == 0
    return 0 if counts.sum + counts.size - 1 > springs.size

    first_size, rest_sizes = counts[0], counts[1..-1]
    first_ok = springs.chars.find_index(?#) || springs.size - 1
    total = [*0..first_ok]
        .filter_map{ _1 if springs[_1..] =~/^[#?]{#{first_size}}[\.\?X]/ }
        .map{ count_options(springs[_1+first_size+1..] || '', rest_sizes) }
        .sum
    $mem[[springs, counts]] = total
    total
end

def count_options_p2 springs, counts
    springs = 5.times.map{ springs }.join ??
    count_options(springs, counts * 5)
end

PART1 = SPRINGS.map{ count_options(_1, _2) }.sum
PART2 = SPRINGS.map{ count_options_p2(_1, _2) }.sum

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
