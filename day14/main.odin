package day14

import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

Vector2 :: [2]int
ARRAY_LENGTH :: 500

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  map_dimensions := Vector2{101, 103}
  bot_count := 0
  positions: [ARRAY_LENGTH]Vector2
  velocities: [ARRAY_LENGTH]Vector2

  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    value_it := line
    for value_str in strings.split_iterator(&value_it, " ") {
      xy_it := value_str[2:]
      x_str := strings.split_iterator(&xy_it, ",") or_else panic(line)
      y_str := strings.split_iterator(&xy_it, ",") or_else panic(line)
      x := strconv.atoi(x_str)
      y := strconv.atoi(y_str)
      switch value_str[0] {
      case 'p':
        positions[bot_count] = Vector2{x, y}
      case 'v':
        velocities[bot_count] = Vector2{x, y}
      case:
        panic(line)
      }
    }

    bot_count += 1
  }

  map_dimensions_array: [ARRAY_LENGTH][2]int
  slice.fill(map_dimensions_array[:], map_dimensions)

  positions = (positions + (velocities + map_dimensions_array) * 100) % map_dimensions_array

  top_left_bots, top_right_bots, bottom_left_bots, bottom_right_bots: int

  middle_pos := map_dimensions / 2

  for pos in positions[:bot_count] {
    switch {
    case pos.x < middle_pos.x && pos.y < middle_pos.y:
      top_left_bots += 1
    case pos.x > middle_pos.x && pos.y < middle_pos.y:
      top_right_bots += 1
    case pos.x < middle_pos.x && pos.y > middle_pos.y:
      bottom_left_bots += 1
    case pos.x > middle_pos.x && pos.y > middle_pos.y:
      bottom_right_bots += 1
    }
  }

  result := top_left_bots * top_right_bots * bottom_left_bots * bottom_right_bots

  fmt.printfln("Safty factor: %v", result)
}

task2 :: proc() {
  map_dimensions := Vector2{101, 103}
  bot_count := 0
  start_positions: [ARRAY_LENGTH]Vector2
  velocities: [ARRAY_LENGTH]Vector2

  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    value_it := line
    for value_str in strings.split_iterator(&value_it, " ") {
      xy_it := value_str[2:]
      x_str := strings.split_iterator(&xy_it, ",") or_else panic(line)
      y_str := strings.split_iterator(&xy_it, ",") or_else panic(line)
      x := strconv.atoi(x_str)
      y := strconv.atoi(y_str)
      switch value_str[0] {
      case 'p':
        start_positions[bot_count] = Vector2{x, y}
      case 'v':
        velocities[bot_count] = Vector2{x, y}
      case:
        panic(line)
      }
    }

    bot_count += 1
  }

  positions := start_positions

  map_dimensions_array: [ARRAY_LENGTH]Vector2
  slice.fill(map_dimensions_array[:], map_dimensions)

  middle_pos := map_dimensions / 2

  up := Vector2{0, -1}
  down := Vector2{0, 1}
  left := Vector2{-1, 0}
  right := Vector2{1, 0}

  min_no_neighbors := max(int)
  min_no_neighbors_i: int

  for it_count := 1; true; it_count += 1 {
    positions = (positions + velocities + map_dimensions_array) % map_dimensions_array

    no_neighbor_count := 0
    outer: for pos in positions[:bot_count] {
      neighbors := [4]Vector2 {
        (pos + up + map_dimensions) % map_dimensions,
        (pos + down + map_dimensions) % map_dimensions,
        (pos + left + map_dimensions) % map_dimensions,
        (pos + right + map_dimensions) % map_dimensions,
      }
      for other in positions[:bot_count] {
        for neighbor in neighbors {
          if neighbor == other {
            continue outer
          }
        }
      }
      no_neighbor_count += 1
    }

    if no_neighbor_count < min_no_neighbors {
      min_no_neighbors = no_neighbor_count
      min_no_neighbors_i = it_count
    }

    if positions == start_positions {
      break
    }
  }

  positions = start_positions
  for _ in 1 ..= min_no_neighbors_i {
    positions = (positions + velocities + map_dimensions_array) % map_dimensions_array
  }

  fmt.printfln("Fewest number of seconds: %v", min_no_neighbors_i)
}
