package day6

import "core:fmt"
import "core:strings"

input := #load("input.txt", string)

Vector2 :: [2]int

PosDir :: struct {
  pos: Vector2,
  dir: Vector2,
}

pos_was_visited :: proc(visited: []Vector2, pos: Vector2) -> bool {
  for other in visited {
    if other == pos do return true
  }
  return false
}

pos_dir_was_visited :: proc(visited: []PosDir, pos_dir: PosDir) -> bool {
  for other in visited {
    if other == pos_dir do return true
  }
  return false
}

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  lines := make([dynamic]string)
  defer delete(lines)
  width: int
  height: int
  {
    lines_split := strings.split_lines(input)
    defer delete(lines_split)

    for line in lines_split {
      if len(line) > 0 {
        if width != 0 do assert(len(line) == width)
        else do width = len(line)
        height += 1
        append(&lines, line)
      }
    }
  }

  up :: Vector2{0, -1}
  down :: Vector2{0, 1}
  left :: Vector2{-1, 0}
  right :: Vector2{1, 0}

  guard_pos: Vector2
  guard_dir: Vector2
  for line, y in lines {
    for char, x in line {
      switch char {
      case '^':
        guard_pos = {x, y}
        guard_dir = up
      case 'v':
        guard_pos = {x, y}
        guard_dir = down
      case '<':
        guard_pos = {x, y}
        guard_dir = left
      case '>':
        guard_pos = {x, y}
        guard_dir = right
      }
    }
  }
  assert(guard_dir == up || guard_dir == down || guard_dir == left || guard_dir == right)

  visited := make([dynamic]Vector2)
  defer delete(visited)

  for {
    if !pos_was_visited(visited[:], guard_pos) {
      append(&visited, guard_pos)
    }

    next_pos := guard_pos + guard_dir
    if next_pos.x < 0 || next_pos.x >= width || next_pos.y < 0 || next_pos.y >= height {
      break
    }

    if lines[next_pos.y][next_pos.x] == '#' {
      switch guard_dir {
      case up:
        guard_dir = right
      case right:
        guard_dir = down
      case down:
        guard_dir = left
      case left:
        guard_dir = up
      }
    } else {
      guard_pos = next_pos
    }
  }

  fmt.printfln("Distinct positions visited: %v", len(visited))
}

task2 :: proc() {
  lines: [dynamic]string
  defer delete(lines)

  width: int
  height: int
  {
    lines_split := strings.split_lines(input)
    defer delete(lines_split)

    for line in lines_split {
      if len(line) > 0 {
        if width != 0 do assert(len(line) == width)
        else do width = len(line)
        height += 1
        append(&lines, line)
      }
    }
  }

  up :: Vector2{0, -1}
  down :: Vector2{0, 1}
  left :: Vector2{-1, 0}
  right :: Vector2{1, 0}

  guard_pos: Vector2
  guard_dir: Vector2
  for line, y in lines {
    for char, x in line {
      switch char {
      case '^', 'v', '>', '<':
        guard_pos = {x, y}
      }
      switch char {
      case '^':
        guard_dir = up
      case 'v':
        guard_dir = down
      case '<':
        guard_dir = left
      case '>':
        guard_dir = right
      }
    }
  }
  assert(guard_dir == up || guard_dir == down || guard_dir == left || guard_dir == right)

  original_guard_pos := guard_pos
  original_guard_dir := guard_dir

  original_path: [dynamic]Vector2
  defer delete(original_path)

  for {
    if !pos_was_visited(original_path[:], guard_pos) {
      append(&original_path, guard_pos)
    }

    next_pos := [2]int{int(guard_pos.x) + int(guard_dir.x), int(guard_pos.y) + int(guard_dir.y)}
    if next_pos.x < 0 || next_pos.x >= width || next_pos.y < 0 || next_pos.y >= height {
      break
    }

    if lines[next_pos.y][next_pos.x] == '#' {
      switch guard_dir {
      case up:
        guard_dir = right
      case right:
        guard_dir = down
      case down:
        guard_dir = left
      case left:
        guard_dir = up
      }
    } else {
      guard_pos = {next_pos.x, next_pos.y}
    }
  }

  loop_count := 0

  visited: [dynamic]PosDir
  defer delete(visited)

  for extra_obstacle in original_path {
    if extra_obstacle == original_guard_pos do continue

    clear(&visited)

    guard_pos := original_guard_pos
    guard_dir := original_guard_dir

    for {
      if pos_dir_was_visited(visited[:], PosDir{guard_pos, guard_dir}) {
        loop_count += 1
        break
      } else {
        append(&visited, PosDir{guard_pos, guard_dir})
      }

      next_pos := [2]int{int(guard_pos.x) + int(guard_dir.x), int(guard_pos.y) + int(guard_dir.y)}
      if next_pos.x < 0 || next_pos.x >= width || next_pos.y < 0 || next_pos.y >= height {
        break
      }

      if next_pos.x == int(extra_obstacle.x) && next_pos.y == int(extra_obstacle.y) ||
         lines[next_pos.y][next_pos.x] == '#' {
        switch guard_dir {
        case up:
          guard_dir = right
        case right:
          guard_dir = down
        case down:
          guard_dir = left
        case left:
          guard_dir = up
        }
      } else {
        guard_pos = {next_pos.x, next_pos.y}
      }
    }
  }

  fmt.printfln("Distinct positions visited with obstacles: %v", loop_count)
}
