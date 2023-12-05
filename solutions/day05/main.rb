#!/usr/bin/ruby

DATA = File.read('data.txt').split("\n\n")

SEEDS = DATA.first.scan(/\d+/).map(&:to_i)

MAPPINGS = DATA[1..].map do |x|
    x.lines.first =~ /(\w+)-to-(\w+) map:/
    from = $1.to_sym
    to = $2.to_sym

    ranges = x.lines[1..].map do |y|
        a, b, c  = y.scan(/\d+/).map(&:to_i)
        range_source = b...(b+c)
        range_dest = a...(a+c)
        [range_dest, range_source]
    end

    {
        from: from,
        to: to,
        ranges: ranges,
    }
end

ORDER = %i(seed soil fertilizer water light temperature humidity)

def parse_seed(seed)
    r = ORDER.each_with_object({x: seed}) do |k, val|
        mapping = MAPPINGS.find{ _1[:from] == k }
        ranges = mapping[:ranges].find{ [_1, _2]; _2.include? val[:x] }
        r = val[:x] + (ranges ? ranges[0].begin - ranges[1].begin : 0)
        val[:x] = r
    end
    r[:x]
end

def get_points ranges
    ranges.map{ [_1.first, _1.last] }.flatten.sort.uniq
end

def compute_distinct_range_points
    order = (%i(location) + ORDER.reverse[...-1])
    mem = []
    order.each do |k|
        mapping = MAPPINGS.find{ _1[:to] == k }
        extra_points = []
        mem.each do |point|
            f, t = mapping[:ranges].find{ _1.first.include? point }
            if f and t
                offset = f.first - t.first
                extra_points << point - offset
            else
                extra_points << point
            end
        end
        points = get_points(mapping[:ranges].map(&:last).flatten)
        mem = (points + extra_points).sort.uniq
    end
    mem
end

POINTS = compute_distinct_range_points

RANGES = POINTS.each_cons(2).map do |a, b|
    range = a...b
    offset = parse_seed(a) - a
    [range, offset]
end

SEED_RANGES = SEEDS.each_slice(2).map do |seeds|
    a, b = seeds
    (a...(a+b))
end

PART1 = SEEDS.map do |seed|
    parse_seed seed
end.min

PART2 = SEED_RANGES.map do |range|
    POINTS.select{ range.include? _1 } + [range.min]
end.flatten.sort.uniq.map do |seed|
    parse_seed seed
end.min

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
