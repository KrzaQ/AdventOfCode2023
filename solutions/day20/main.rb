#!/usr/bin/ruby

DATA = File.read('data.txt').scan(/([%&\w]+) -> ([\w ,]+)/).map do |a, b|
    type, name = case a[0]
    when ?&
        [:conjunction, a[1..-1]]
    when ?%
        [:flipflop, a[1..-1]]
    when ?b
        [:broadcaster, a]
    else
        raise "Unknown type: #{a}"
    end
    v = {
        name: name.to_sym,
        type: type,
        outputs: b.split(', ').map{ _1.strip.to_sym }
    }
    [v[:name], v]
end.to_h.then do |h|
    h.each do |k, v|
        v[:outputs].each do |o|
            next unless h[o]
            h[o][:inputs] ||= []
            h[o][:inputs] << k
        end
    end
    h
end.then do |h|
    h.each do |k, v|
        if v[:type] == :conjunction
            v[:remembered] = v[:inputs].map{ [_1, 0] }.to_h
        elsif v[:type] == :flipflop
            v[:value] = 0
        end
    end
    h
end

def process_button state = {}
    todo = [[:broadcaster, 0, :button]]
    pulses = [1, 0]
    while todo.any?
        name, pulse_value, sender = todo.shift
        node = state[name]
        next unless node
        next unless node[:type]
        case node[:type]
        when :broadcaster
            node[:outputs].each{ todo << [_1, pulse_value, name] }
            pulses[pulse_value] += node[:outputs].size
        when :flipflop
            if pulse_value == 0
                node[:value] = 1 - node[:value]
                node[:outputs].each{ todo << [_1, node[:value], name] }
                pulses[node[:value]] += node[:outputs].size
            end
        when :conjunction
            node[:remembered][sender] = pulse_value
            val = node[:inputs].all?{ node[:remembered][_1] == 1 } ? 0 : 1
            node[:outputs].each{ todo << [_1, val, name] }
            pulses[val] += node[:outputs].size
        end
    end
    [*pulses, state]
end

def part1
    1000.times
        .each_with_object(DATA.dup)
        .map{ l, h, _ = process_button _2.dup; [l, h] }
        .transpose
        .map(&:sum)
        .inject(:*)
end

def get_cycles node
    s = DATA.map{ [_1, _2.dup] }.to_h
    s[:broadcaster][:outputs] = [node]
    saved_first = s.map { [_1, _2.dup] }.to_h
    values = []
    (1..).map do |i|
        l, h, s = process_button s.dup
        return i if s == saved_first
    end
end

def part2
    DATA[:broadcaster][:outputs].map do |node|
        get_cycles node
    end.inject(:lcm)
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
