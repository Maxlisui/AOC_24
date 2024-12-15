package day15

import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

Vector2 :: [2]int

Warehouse :: struct {
  data:          [dynamic]u8,
  width, height: int,
}

UP := Vector2{0, -1}
DOWN := Vector2{0, 1}
LEFT := Vector2{-1, 0}
RIGHT := Vector2{1, 0}

warehouse_at :: proc {
  warehouse_at_val,
  warehouse_at_ptr,
}

warehouse_at_val :: proc(using warehouse: Warehouse, pos: Vector2) -> u8 {
  return data[pos.y * width + pos.x]
}

warehouse_at_ptr :: proc(using warehouse: ^Warehouse, pos: Vector2) -> ^u8 {
  return &data[pos.y * width + pos.x]
}

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  warehouse: Warehouse
  defer delete(warehouse.data)

  robo_pos: Vector2

  lines_it := input
  for line in strings.split_lines_iterator(&lines_it) {
    if len(line) == 0 {
      break
    }

    if warehouse.width == 0 {
      warehouse.width = len(line)
    } else {
      assert(len(line) == warehouse.width, line)
    }
    warehouse.height += 1

    append(&warehouse.data, ..transmute([]u8)line)
  }

  for y in 0 ..< warehouse.height {
    for x in 0 ..< warehouse.width {
      pos := Vector2{x, y}
      if warehouse_at(&warehouse, pos)^ == '@' {
        robo_pos = Vector2{x, y}
      }
    }
  }

  moves: [dynamic]Vector2
  defer delete(moves)

  for char in transmute([]u8)lines_it {
    switch char {
    case '^':
      append(&moves, UP)
    case 'v':
      append(&moves, DOWN)
    case '<':
      append(&moves, LEFT)
    case '>':
      append(&moves, RIGHT)
    }
  }

  for move in moves {
    pos := robo_pos
    loop: for ;; pos += move {
      switch warehouse_at(warehouse, pos) {
      case '@', 'O':
        continue loop
      case '.', '#':
        break loop
      case:
        panic("Unexpected character")
      }
    }

    move_is_valid := warehouse_at(warehouse, pos) != '#'
    if move_is_valid {
      for ; pos != robo_pos; pos -= move {
        here := warehouse_at(&warehouse, pos)
        there := warehouse_at(&warehouse, pos - move)
        assert(here^ == '.')
        here^ = there^
        there^ = '.'
      }
      robo_pos += move
    }
  }

  result := 0

  for char, i in warehouse.data {
    if char == 'O' {
      pos := Vector2{i % warehouse.width, i / warehouse.width}
      gps_coordinate := pos.x + 100 * pos.y
      result += gps_coordinate
    }
  }

  fmt.printfln("Sum of all boxes' GPS coordinates: %v", result)
}

task2 :: proc() {
  warehouse: Warehouse
  defer delete(warehouse.data)

  lines_it := input
  for line in strings.split_lines_iterator(&lines_it) {
    if len(line) == 0 {
      break
    }

    if warehouse.width == 0 {
      warehouse.width = len(line) * 2
    } else {
      assert(len(line) * 2 == warehouse.width, line)
    }
    warehouse.height += 1

    for char in transmute([]u8)line {
      switch char {
      case '#', '.':
        append(&warehouse.data, char)
        append(&warehouse.data, char)
      case '@':
        append(&warehouse.data, '@')
        append(&warehouse.data, '.')
      case 'O':
        append(&warehouse.data, '[')
        append(&warehouse.data, ']')
      case:
        panic(line)
      }
    }
  }

  moves: [dynamic]Vector2
  defer delete(moves)

  for char in transmute([]u8)lines_it {
    switch char {
    case '^':
      append(&moves, UP)
    case 'v':
      append(&moves, DOWN)
    case '<':
      append(&moves, LEFT)
    case '>':
      append(&moves, RIGHT)
    }
  }

  for move in moves {
    robo_pos: Vector2
    for y in 0 ..< warehouse.height {
      for x in 0 ..< warehouse.width {
        pos := Vector2{x, y}
        if warehouse_at(&warehouse, pos)^ == '@' {
          robo_pos = pos
        }
      }
    }

    affected_positions: map[Vector2]u8
    defer delete(affected_positions)

    frontier: [dynamic]Vector2
    defer delete(frontier)

    append(&frontier, robo_pos)

    is_valid_move := true

    for len(frontier) > 0 && is_valid_move {
      pos := pop(&frontier)
      char := warehouse_at(warehouse, pos)
      switch char {
      case '@':
        append(&frontier, pos + move)
        affected_positions[pos] = 1
      case '[':
        append(&frontier, pos + move)
        affected_positions[pos] = 1
        if pos + RIGHT not_in affected_positions {
          append(&frontier, pos + RIGHT)
        }
      case ']':
        append(&frontier, pos + move)
        affected_positions[pos] = 1
        if pos + LEFT not_in affected_positions {
          append(&frontier, pos + LEFT)
        }
      case '#':
        is_valid_move = false
      case '.':
        {}
      case:
        panic("unknown char")
      }
    }

    warehouse_copy := Warehouse {
      width  = warehouse.width,
      height = warehouse.height,
    }
    defer delete(warehouse_copy.data)

    append(&warehouse_copy.data, ..warehouse.data[:])

    if is_valid_move {
      for pos in affected_positions {
        here := warehouse_at(&warehouse, pos)
        here^ = '.'
      }

      for pos in affected_positions {
        here := warehouse_at(warehouse_copy, pos)
        there := warehouse_at(&warehouse, pos + move)
        there^ = here
      }
    }
  }

  result := 0

  for char, i in warehouse.data {
    if char == '[' {
      pos := Vector2{i % warehouse.width, i / warehouse.width}
      gps_coordinate := pos.x + 100 * pos.y
      result += gps_coordinate
    }
  }

  fmt.printfln("Sum of all boxes' GPS coordinates, with scaled-up warehouse: %v", result)
}
