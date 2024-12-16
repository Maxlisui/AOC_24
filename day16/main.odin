package day16

import "core:fmt"
import "core:strings"

input := #load("input.txt", string)

Vector2 :: [2]int

Transform :: struct {
  pos: Vector2,
  dir: Direction,
}

DirectionCosts :: [Direction]int

Plan :: struct($T: typeid) {
  data:   [dynamic]T,
  width:  int,
  height: int,
}

Direction :: enum {
  Up,
  Right,
  Down,
  Left,
}

direction_to_vector2 :: proc(dir: Direction) -> Vector2 {
  result: Vector2
  switch dir {
  case .Up:
    result = Vector2{0, -1}
  case .Down:
    result = Vector2{0, 1}
  case .Left:
    result = Vector2{-1, 0}
  case .Right:
    result = Vector2{1, 0}
  }
  return result
}

direction_next_clockwise :: proc(dir: Direction) -> Direction {
  return Direction((int(dir) + 1) % len(Direction))
}

direction_next_ccv :: proc(dir: Direction) -> Direction {
  return Direction((int(dir) + len(Direction) - 1) % len(Direction))
}

plan_at_ptr :: proc(plan: Plan($T), pos: Vector2) -> ^T {
  return &plan.data[plan_index(plan, pos)]
}

plan_at :: proc(plan: Plan($T), pos: Vector2) -> T {
  return plan.data[plan_index(plan, pos)]
}

plan_in_bounds :: proc(plan: Plan($T), pos: Vector2) -> bool {
  return pos.x >= 0 && pos.x < plan.width && pos.y >= 0 && pos.y < plan.height
}

plan_index :: proc(plan: Plan($T), pos: Vector2) -> int {
  return pos.y * plan.width + pos.x
}

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  plan := parse_plan()
  defer delete(plan.data)

  cost, start_pos, end_pos := make_cost_plan(plan)
  defer delete(cost.data)
  assert(start_pos != {})
  assert(end_pos != {})

  min_cost := calculate_min_target_cost(plan, cost, start_pos, end_pos)

  fmt.printfln("Lowest score: %v", min_cost)
}

task2 :: proc() {
  plan := parse_plan()
  defer delete(plan.data)

  cost, start_pos, end_pos := make_cost_plan(plan)
  defer delete(cost.data)
  assert(start_pos != {})
  assert(end_pos != {})

  min_cost := calculate_min_target_cost(plan, cost, start_pos, end_pos)

  best_path_tiles: map[Vector2]struct {}
  defer delete(best_path_tiles)

  path_frontier: [dynamic]Transform
  defer delete(path_frontier)

  for cost, dir in plan_at(cost, end_pos) {
    if cost == min_cost {
      best_path_tiles[end_pos] = {}
      append(&path_frontier, Transform{pos = end_pos, dir = dir})
    }
  }

  for len(path_frontier) > 0 {
    current := pop(&path_frontier)
    current_cost := plan_at(cost, current.pos)[current.dir]

    candidates := []Transform {
      Transform{pos = current.pos, dir = direction_next_clockwise(current.dir)},
      Transform{pos = current.pos, dir = direction_next_ccv(current.dir)},
      Transform{pos = current.pos - direction_to_vector2(current.dir), dir = current.dir},
    }

    for candidate in candidates {
      if !plan_in_bounds(plan, candidate.pos) {
        continue
      }

      assert(plan_in_bounds(cost, candidate.pos))

      if plan_at(plan, candidate.pos) == '#' {
        continue
      }

      candidate_cost := current_cost - (1 if candidate.dir == current.dir else 1000)
      if plan_at(cost, candidate.pos)[candidate.dir] != candidate_cost {
        continue
      }

      best_path_tiles[candidate.pos] = {}
      append(&path_frontier, candidate)
    }
  }

  num_tiles := len(best_path_tiles)

  fmt.printfln("Number of tiles: %v", num_tiles)
}

parse_plan :: proc() -> Plan(u8) {
  plan: Plan(u8)
  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    if plan.width != 0 {
      assert(len(line) == plan.width)
    }
    plan.width = len(line)
    plan.height += 1
    append(&plan.data, ..transmute([]u8)line)
  }
  return plan
}

make_cost_plan :: proc(
  plan: Plan($T),
) -> (
  cost: Plan(DirectionCosts),
  start_pos: Vector2,
  end_pos: Vector2,
) {
  cost.width = plan.width
  cost.height = plan.height

  for y in 0 ..< plan.height {
    for x in 0 ..< plan.width {
      pos := Vector2{x, y}
      if plan_at(plan, pos) == 'S' {
        start_pos = pos
      }
      if plan_at(plan, pos) == 'E' {
        end_pos = pos
      }

      append(
        &cost.data,
        DirectionCosts{.Up = max(int), .Right = max(int), .Down = max(int), .Left = max(int)},
      )
    }
  }
  return
}

calculate_min_target_cost :: proc(
  plan: Plan(u8),
  cost: Plan(DirectionCosts),
  start_pos, end_pos: Vector2,
) -> int {
  frontier: [dynamic]Transform
  defer delete(frontier)

  append(&frontier, Transform{pos = start_pos, dir = .Right})

  plan_at_ptr(cost, start_pos)[.Right] = 0

  for len(frontier) > 0 {
    current := pop(&frontier)
    current_cost := plan_at(cost, current.pos)[current.dir]

    candidates := []Transform {
      Transform{pos = current.pos, dir = direction_next_clockwise(current.dir)},
      Transform{pos = current.pos, dir = direction_next_ccv(current.dir)},
      Transform{pos = current.pos + direction_to_vector2(current.dir), dir = current.dir},
    }

    for candidate in candidates {
      if !plan_in_bounds(plan, candidate.pos) {
        continue
      }

      assert(plan_in_bounds(cost, candidate.pos))

      if plan_at(plan, candidate.pos) == '#' {
        continue
      }

      candidate_cost := current_cost + (1 if candidate.dir == current.dir else 1000)
      cost_ptr := plan_at_ptr(cost, candidate.pos)
      if cost_ptr[candidate.dir] <= candidate_cost {
        continue
      }

      cost_ptr[candidate.dir] = candidate_cost
      append(&frontier, candidate)
    }
  }

  min_target_cost := max(int)
  for cost in plan_at(cost, end_pos) {
    min_target_cost = min(min_target_cost, cost)
  }

  return min_target_cost
}
