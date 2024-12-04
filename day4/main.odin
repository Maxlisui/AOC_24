package day4

import "core:fmt"

input := #load("input.txt", string)

DIRECTIONS :: [][2]int {
  {0, 1}, // Right
  {1, 0}, // Down
  {1, 1}, // Diagonal down-right
  {1, -1}, // Diagonal down-left
}

main :: proc() {
  task1()
  task2()
}

valid_position :: proc(grid: [dynamic][dynamic]u8, row, col: int) -> bool {
  return row >= 0 && row < len(grid) && col >= 0 && col < len(grid[row])
}

find_word :: proc(
  grid: [dynamic][dynamic]u8,
  word: string,
  start_row, start_col: int,
  direction: [2]int,
) -> bool {
  for i in 0 ..< len(word) {
    r := start_row + i * direction[0]
    c := start_col + i * direction[1]
    if !valid_position(grid, r, c) || grid[r][c] != word[i] {
      return false
    }
  }
  return true
}
matches_diagonal :: proc(grid: [dynamic][dynamic]u8, row, col: int, dr, dc: int) -> bool {
  mas := "MAS"
  sam := "SAM"

  word: string
  if grid[row][col] == 'M' {
    word = mas
  } else if grid[row][col] == 'S' {
    word = sam
  } else {
    return false
  }

  for i in 1 ..< 3 {
    r := row + i * dr
    c := col + i * dc
    if valid_position(grid, r, c) {
      b := grid[r][c]
      if b != word[i] {
        return false
      }
    } else {
      return false
    }
  }
  return true
}

is_valid_xmas :: proc(grid: [dynamic][dynamic]u8, row, col: int) -> bool {
  if grid[row][col] != 'A' {
    return false
  }

  top_left_to_bottom_right := matches_diagonal(grid, row - 1, col - 1, 1, 1)
  top_right_to_bottom_left := matches_diagonal(grid, row - 1, col + 1, 1, -1)

  return top_left_to_bottom_right && top_right_to_bottom_left
}

find_xmas :: proc(grid: [dynamic][dynamic]u8) -> int {
  count := 0

  for row in 1 ..< len(grid) - 1 {
    for col in 1 ..< len(grid[row]) - 1 {
      if is_valid_xmas(grid, row, col) {
        count += 1
      }
    }
  }

  return count
}

task1 :: proc() {
  grid := make([dynamic][dynamic]u8)
  defer {
    for row in grid {
      delete(row)
    }
    delete(grid)
  }

  current_row := make([dynamic]u8)
  for i := 0; i < len(input); i += 1 {
    if input[i] == '\r' {
      continue
    }

    if input[i] == '\n' {
      append(&grid, current_row)
      current_row = make([dynamic]u8)
      continue
    }

    append(&current_row, input[i])
  }

  if len(current_row) > 0 {
    append(&grid, current_row)
  }

  count := 0
  words_to_find := []string{"XMAS", "SAMX"}
  for row in 0 ..< len(grid) {
    for col in 0 ..< len(grid[row]) {
      for word in words_to_find {
        for direction in DIRECTIONS {
          if find_word(grid, word, row, col, direction) {
            count += 1
          }
        }
      }
    }
  }

  fmt.printfln("XMAS Count: %v", count)
}

task2 :: proc() {
  grid := make([dynamic][dynamic]u8)
  defer {
    for row in grid {
      delete(row)
    }
    delete(grid)
  }

  current_row := make([dynamic]u8)
  for i := 0; i < len(input); i += 1 {
    if input[i] == '\r' {
      continue
    }

    if input[i] == '\n' {
      append(&grid, current_row)
      current_row = make([dynamic]u8)
      continue
    }

    append(&current_row, input[i])
  }

  if len(current_row) > 0 {
    append(&grid, current_row)
  }

  count := find_xmas(grid)

  fmt.printfln("X-MAS Count: %v", count)
}
