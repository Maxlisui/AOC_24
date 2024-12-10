package day8

import "core:fmt"
import "core:strings"

input := #load("input.txt", string)

Vector2 :: [2]int

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  antennas, bounds := parse_input()
  defer {
    for key in antennas do delete(antennas[key])
    delete(antennas)
  }

  antinodes: map[Vector2]u8
  defer delete(antinodes)

  for key in antennas {
    key_antennas := antennas[key]
    for antenna_a, i in key_antennas[:len(key_antennas) - 1] {
      for antenna_b in key_antennas[i + 1:] {
        pos_diff := antenna_a - antenna_b
        maybe_antinodes := [2]Vector2{antenna_a + pos_diff, antenna_b - pos_diff}
        for antinode in maybe_antinodes {
          if in_bounds(bounds, antinode) {
            antinodes[antinode] = 1
          }
        }
      }
    }
  }

  fmt.printfln("Number of antinodes: %v", len(antinodes))
}

task2 :: proc() {
  antennas, bounds := parse_input()
  defer {
    for key in antennas do delete(antennas[key])
    delete(antennas)
  }

  antinodes: map[Vector2]u8
  defer delete(antinodes)

  for key in antennas {
    key_antennas := antennas[key]
    for antenna_a, i in key_antennas[:len(key_antennas) - 1] {
      for antenna_b in key_antennas[i + 1:] {
        pos_diff := antenna_a - antenna_b
        for antinode := antenna_a; in_bounds(bounds, antinode); antinode += pos_diff {
          antinodes[antinode] = 1
        }
        for antinode := antenna_b; in_bounds(bounds, antinode); antinode -= pos_diff {
          antinodes[antinode] = 1
        }
      }
    }
  }

  fmt.printfln("Number of antinodes with updated model: %v", len(antinodes))
}

parse_input :: proc() -> (antennas: map[u8][dynamic]Vector2, bounds: Vector2) {
  lines := make([dynamic][]u8)
  defer delete(lines)

  lines_split := strings.split_lines(input)
  defer delete(lines_split)

  for line in lines_split {
    if len(line) > 0 do append(&lines, transmute([]u8)line)
  }

  bounds = Vector2{len(lines), len(lines[0])}
  antennas = make(map[u8][dynamic]Vector2)

  for line, y in lines {
    for char, x in line {
      if char != '.' {
        if char not_in antennas do antennas[char] = nil
        append(&antennas[char], Vector2{x, y})
      }
    }
  }
  return
}

in_bounds :: proc(bounds: Vector2, pos: Vector2) -> bool {
  return pos.x >= 0 && pos.x < bounds.x && pos.y >= 0 && pos.y < bounds.y
}
