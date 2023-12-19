#!/usr/bin/ruby

require 'set'

DATA1, DATA2 = File.read('data.txt').split("\n\n")

RULES = DATA1.lines.map do |line|
    name, rules = line.scan(/(\w+)\{(.*?)\}/).first
    rules = rules.split(?,).map{ _1.split ?: }
    [name, rules]
end.to_h

PARTS = DATA2.lines.map do |line|
    x = line.scan(/(\w)=(\d+)/).map{ |x| [x[0], x[1].to_i] }.to_h
    x
end

def eval_rule part, rule = "in"
    return rule if %w(R A).include? rule
    for r in RULES[rule]
        pred, next_rule = r
        return eval_rule part, pred unless next_rule
        a = part[?a]
        s = part[?s]
        m = part[?m]
        x = part[?x]
        if eval pred
            return eval_rule part, next_rule
        end
    end
    nil
end

xx = PARTS.select do |part|
    p part
    eval_rule(part) == ?A
end.map do |part|
    part.values.sum
end
p xx.sum
class Range
    def intersection(other)
        # p [self, other]
        raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)

        my_min, my_max = first, exclude_end? ? max : last
        other_min, other_max = other.first, other.exclude_end? ? other.max : other.last

        new_min = self === other_min ? other_min : other === my_min ? my_min : nil
        new_max = self === other_max ? other_max : other === my_max ? my_max : nil

        new_min && new_max ? new_min..new_max : nil
    end

    alias_method :&, :intersection
end
all = RULES.map do |k, v|
    vs = v.reject do |x|
        x[1] == nil
    end.map do |x|
        rating, value = x[0].split(/[<>]/)
        [rating, value.to_i]
    end
    vs
end.flatten(1).inject({}) do |acc, x|
    rating, value = x
    acc[rating] ||= Set.new
    acc[rating] << value
    acc
end.map do |k, v|
    vals = v.to_a.sort
    vals = [1] + vals unless vals[0] == 1
    vals << 4001
    ranges = vals.each_cons(2).map do |a, b|
        (a...b)
    end
    [k, ranges]
end

def match_rule part, val, op, rating
    r = case op
    when ?<
        (1..rating.pred) & part[val]
    when ?>
        (rating.succ..4000) & part[val]
    end
    r && r.size > 0
end

def split_range ranges, val, op, rating
    # p [val, op, rating, ranges]
    case op
    when ?<
        r = ranges[val]
        if r.include? rating
            r1 = ranges.map do |k, v|
                [k, v.dup]
            end.to_h
            r1[val] = (r.begin..rating.pred)
            ranges[val] = (rating..r.end)
            [r1, ranges]
        else
            [ranges]
        end
        # if r.end > rating
        #     r1 = ranges.map do |k, v|
        #         [k, v.dup]
        #     end.to_h
        #     r1[val] = (r.begin..rating.pred)
        #     ranges[val] = (rating..r.end)
        #     [r1, ranges]
        # else
        #     [ranges]
        # end
    when ?>
        r = ranges[val]
        if r.include? rating
            r1 = ranges.map do |k, v|
                [k, v.dup]
            end.to_h
            r1[val] = (r.begin..rating)
            ranges[val] = (rating.succ..r.end)
            [r1, ranges]
        else
            [ranges]
        end
        # if r.begin < rating
        #     r1 = ranges.map do |k, v|
        #         [k, v.dup]
        #     end.to_h
        #     r1[val] = (r.begin..rating)
        #     ranges[val] = (rating.succ..r.end)
        #     [r1, ranges]
        # else
        #     [ranges]
        # end
    end
end

def dfs ranges = { ?x => 1..4000, ?m => 1..4000, ?a => 1..4000, ?s => 1..4000 }, rule = "in"
    # p [ranges, rule]
    return [ranges] if rule == ?A
    return [] if rule == ?R
    res = []
    for r in RULES[rule]
        pred, next_rule = r
        return [res + dfs(ranges, pred)].flatten unless next_rule
        val, op, rating = pred.scan(/(\w+)([<>])(\d+)/).first
        rating = rating.to_i
        # p [val, op, rating, pred]
        has_match = match_rule ranges, val, op, rating
        next unless has_match

        rngs = split_range ranges.dup, val, op, rating
        # p [:split, rule, ranges, rngs.size, rngs]

        if rngs.size == 1
            result = dfs rngs.first, next_rule
            # p [:add, result] if result.size > 0
            res << result if result.size > 0
            break
        end

        for rng in rngs
            if match_rule rng, val, op, rating
                result = dfs rng, next_rule
                # p [:add, result] if result.size > 0
                res << result if result.size > 0
            else
                ranges = rng
            end
        end

    end
    res.flatten
end

def range_volume range
    range.values.map{ _1.size }.inject(&:*)
end


def part2
    # ranges = dfs.uniq.reject do |x|
    #     part = x.map do |k, v|
    #         [k, v.begin]
    #     end.to_h
    #     eval_rule(part) != ?A
    # end
    ranges = dfs.uniq
    # ranges.each do |r|
    #     p r
    # end
    # exit
    # p ranges
    # ranges.each do |r|
        # part = r.map do |k, v|
            # [k, v.end]
        # end.to_h
        # p [part, eval_rule(part)]
    # end
    # exit
    # negatives = []
    sum = 0
    for i in 0...ranges.size
        r = ranges[i]
        sum += range_volume(r)
        for j in i.succ...ranges.size
            r2 = ranges[j]
            intersection = r.map do |k, v|
                [k, v & r2[k]]
            end.to_h

            if intersection.values.all?
                p [:intersection, intersection, r, r2, ]
                sum -= range_volume(intersection)
            end
        end
    end
    sum
end
p part2
# x = dfs
# p x.uniq
# p x.uniq.size
# p x.uniq.map{ _1.values.map{|r| r.size}.inject(&:*) }.sum

# def part2_dumb ranges
#     p ranges
#     xs = ranges["x"]
#     ms = ranges["m"]
#     as = ranges["a"]
#     ss = ranges["s"]
#     sum = 0
#     for rx in xs
#         for rm in ms
#             for ra in as
#                 for rs in ss
#                     part = {
#                         ?x => rx.begin.succ,
#                         ?m => rm.begin.succ,
#                         ?a => ra.begin.succ,
#                         ?s => rs.begin.succ
#                     }
#                     if eval_rule(part) == ?A
#                         sum += [rx.size, rm.size, ra.size, rs.size].inject(&:*)
#                     end
#                 end
#             end
#         end
#     end
#     sum
# end

# p part2_dumb all.to_h

# p all.map{ |k, v| [k, v.size] }.to_h.values.inject(&:*)

# puts 'Part 1: %s' % area(POINTS_P1)
# puts 'Part 2: %s' % area(POINTS_P2)
