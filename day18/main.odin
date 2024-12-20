package day18

import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

Vector2 :: [2]int
UP :: Vector2{0, -1}
DOWN :: Vector2{0, 1}
LEFT :: Vector2{-1, 0}
RIGHT :: Vector2{1, 0}
DIRS :: []Vector2{UP, DOWN, LEFT, RIGHT}

heuristic :: proc(pos, end_pos: Vector2) -> int {
  return abs(pos.x - end_pos.x) + abs(pos.y - end_pos.y)
}

at_ptr :: proc(list: []$T, dimensions, pos: Vector2) -> ^T {
  return &list[pos.y * dimensions.x + pos.x]
}

at :: proc(list: []$T, dimensions, pos: Vector2) -> T {
  return list[pos.y * dimensions.x + pos.x]
}

out_of_bounds :: proc(pos, dimensions: Vector2) -> bool {
  return pos.x < 0 || pos.x >= dimensions.x || pos.y < 0 || pos.y >= dimensions.y
}

has_path :: proc(field_map: []u8, dimensions: Vector2) -> bool {
  start_pos := Vector2{0, 0}
  end_pos := Vector2{dimensions.x - 1, dimensions.y - 1}

  frontier: map[Vector2]struct {}
  defer delete(frontier)
  frontier[start_pos] = {}

  g_scores := make([]int, dimensions.x * dimensions.y)
  defer delete(g_scores)
  slice.fill(g_scores, max(int))
  at_ptr(g_scores, dimensions, start_pos)^ = 0

  f_scores := make([]int, dimensions.x * dimensions.y)
  defer delete(f_scores)
  slice.fill(f_scores, max(int))
  at_ptr(f_scores, dimensions, start_pos)^ = heuristic(start_pos, end_pos)

  for len(frontier) > 0 {
    f_score := max(int)
    pos: Vector2
    for frontier_pos in frontier {
      score := at(f_scores, dimensions, frontier_pos)
      if score < f_score {
        f_score = score
        pos = frontier_pos
      }
    }

    if pos == end_pos {
      return true
    }

    g_score := at(g_scores, dimensions, pos)

    delete_key(&frontier, pos)

    for dir in DIRS {
      neighbor := pos + dir
      if out_of_bounds(neighbor, dimensions) {
        continue
      }
      is_blocked := at(field_map, dimensions, neighbor) == '#'
      if is_blocked {
        continue
      }

      neighbor_g_score := at_ptr(g_scores, dimensions, neighbor)
      tentative_g_score := g_score + 1
      if tentative_g_score >= neighbor_g_score^ {
        continue
      }

      neighbor_g_score^ = tentative_g_score
      neighbor_f_score := at_ptr(f_scores, dimensions, neighbor)
      neighbor_f_score^ = tentative_g_score + heuristic(neighbor, end_pos)

      frontier[neighbor] = {}
    }
  }

  return false
}

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  it_count := 1024
  dimensions := Vector2{71, 71}

  field_map := make([]u8, dimensions.x * dimensions.y)
  defer delete(field_map)

  slice.fill(field_map, '.')

  it := 0
  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    coord_it := line
    coord := Vector2 {
      strconv.atoi(strings.split_iterator(&coord_it, ",") or_else panic(line)),
      strconv.atoi(strings.split_iterator(&coord_it, ",") or_else panic(line)),
    }
    at_ptr(field_map, dimensions, coord)^ = '#'
    it += 1
    if it == it_count {
      break
    }
  }

  start_pos := Vector2{0, 0}
  end_pos := Vector2{dimensions.x - 1, dimensions.y - 1}

  frontier: map[Vector2]struct {}
  defer delete(frontier)
  frontier[start_pos] = {}

  g_scores := make([]int, dimensions.x * dimensions.y)
  defer delete(g_scores)
  slice.fill(g_scores, max(int))
  at_ptr(g_scores, dimensions, start_pos)^ = 0

  f_scores := make([]int, dimensions.x * dimensions.y)
  defer delete(f_scores)
  slice.fill(f_scores, max(int))
  at_ptr(f_scores, dimensions, start_pos)^ = heuristic(start_pos, end_pos)

  for len(frontier) > 0 {
    f_score := max(int)
    pos: Vector2
    for frontier_pos in frontier {
      score := at(f_scores, dimensions, frontier_pos)
      if score < f_score {
        f_score = score
        pos = frontier_pos
      }
    }

    if pos == end_pos {
      break
    }

    g_score := at(g_scores, dimensions, pos)

    delete_key(&frontier, pos)

    for dir in DIRS {
      neighbor := pos + dir
      if out_of_bounds(neighbor, dimensions) {
        continue
      }
      is_blocked := at(field_map, dimensions, neighbor) == '#'
      if is_blocked {
        continue
      }

      neighbor_g_score := at_ptr(g_scores, dimensions, neighbor)
      tentative_g_score := g_score + 1
      if tentative_g_score >= neighbor_g_score^ {
        continue
      }

      neighbor_g_score^ = tentative_g_score
      neighbor_f_score := at_ptr(f_scores, dimensions, neighbor)
      neighbor_f_score^ = tentative_g_score + heuristic(neighbor, end_pos)

      frontier[neighbor] = {}
    }
  }

  number_of_steps := at(g_scores, dimensions, end_pos)

  fmt.printfln("Minimum number of steps: %v", number_of_steps)
}

task2 :: proc() {
  it_count := 1024
  dimensions := Vector2{71, 71}

  field_map := make([]u8, dimensions.x * dimensions.y)
  defer delete(field_map)
  slice.fill(field_map, '.')

  coord: Vector2
  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    coord_it := line
    coord = Vector2 {
      strconv.atoi(strings.split_iterator(&coord_it, ",") or_else panic(line)),
      strconv.atoi(strings.split_iterator(&coord_it, ",") or_else panic(line)),
    }
    at_ptr(field_map, dimensions, coord)^ = '#'

    if !has_path(field_map, dimensions) {
      break
    }
  }

  fmt.printfln("Coordinates: %v", coord)
}
