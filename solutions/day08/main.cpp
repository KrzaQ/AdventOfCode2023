#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <map>
#include <numeric>
#include <string_view>
#include <string>
#include <utility>

using path_t = std::string_view;
using path_choice_t = std::pair<std::string, std::string>;
using graph_t = std::map<std::string, path_choice_t>;
enum class seek_mode { all_z, last_z };

uint64_t walk_path(path_t const path, std::string_view const start,
    graph_t const& graph, seek_mode mode)
{
    std::string_view current = start;
    for (uint64_t i = 0;; ++i) {
        auto const& [left, right] = graph.at(std::string{current});
        current = path[i % path.size()] == 'L' ? left : right;
        if (mode == seek_mode::all_z ? current == "ZZZ" : current.back() == 'Z')
            return i + 1;
    }
    std::unreachable();
}

uint64_t part1(path_t const path, graph_t const& graph)
{
    return walk_path(path, "AAA", graph, seek_mode::all_z);
}

uint64_t part2(path_t const path, graph_t const& graph)
{
    uint64_t ret = 1;
    for (auto const& [key, value] : graph) {
        if (key.back() != 'A') continue;
        auto n = walk_path(path, key, graph, seek_mode::last_z);
        ret = std::lcm(ret, n);
    }
    return ret;
}

int main()
{
    std::ifstream file("data.txt");
    std::string path;
    file >> path;
    graph_t graph;
    for (std::string line; std::getline(file >> std::ws, line); ) {
        std::string first = line.substr(0, 3);
        std::string second = line.substr(7, 3);
        std::string third = line.substr(12, 3);
        graph[first] = { second, third };
    }
    std::cout << "Part 1: " << part1(path, graph) << '\n';
    std::cout << "Part 2: " << part2(path, graph) << '\n';
}