package day2

import "core:fmt"
import "core:slice"
import "core:strconv"

input := #load("input.txt", string)

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  result := 0

  for i := 0; i < len(input); i += 1 {
    if i + 3 >= len(input) {
      continue
    }

    if input[i:i + 3] != "mul" {
      continue
    }

    i += 3

    if i >= len(input) || input[i] != '(' {
      continue
    }

    i += 1

    arg1_length, arg1_parse_ok := parse_num(input, i)
    if !arg1_parse_ok {
      continue
    }

    arg1, arg1_ok := strconv.parse_int(input[i:i + arg1_length])
    assert(arg1_ok)

    i += arg1_length

    if i >= len(input) || input[i] != ',' {
      continue
    }

    i += 1

    arg2_length, arg2_parse_ok := parse_num(input, i)
    if !arg2_parse_ok {
      continue
    }

    arg2, arg2_ok := strconv.parse_int(input[i:i + arg2_length])
    assert(arg2_ok)


    i += arg2_length

    if i >= len(input) || input[i] != ')' {
      continue
    }

    result += arg1 * arg2
  }

  fmt.printfln("Result is: %v", result)
}

task2 :: proc() {
  result := 0
  enabled := true

  for i := 0; i < len(input); i += 1 {
    if enabled && i + 7 < len(input) {
      if input[i:i + 7] == "don't()" {
        enabled = false
        i += 7
      }
    }
    if !enabled && i + 4 < len(input) {
      if input[i:i + 4] == "do()" {
        enabled = true
        i += 4
      }
    }

    if !enabled {
      continue
    }

    if i + 3 >= len(input) {
      continue
    }

    if input[i:i + 3] != "mul" {
      continue
    }

    i += 3

    if i >= len(input) || input[i] != '(' {
      continue
    }

    i += 1

    arg1_length, arg1_parse_ok := parse_num(input, i)
    if !arg1_parse_ok {
      continue
    }

    arg1, arg1_ok := strconv.parse_int(input[i:i + arg1_length])
    assert(arg1_ok)

    i += arg1_length

    if i >= len(input) || input[i] != ',' {
      continue
    }

    i += 1

    arg2_length, arg2_parse_ok := parse_num(input, i)
    if !arg2_parse_ok {
      continue
    }

    arg2, arg2_ok := strconv.parse_int(input[i:i + arg2_length])
    assert(arg2_ok)


    i += arg2_length

    if i >= len(input) || input[i] != ')' {
      continue
    }

    result += arg1 * arg2
  }

  fmt.printfln("Result with enable/disable is: %v", result)
}

parse_num :: proc(s: string, index: int) -> (length: int, ok: bool) {
  for i := 0; i < 3 && i < len(s); i += 1 {
    c := s[index + i]

    if c == ',' || c == ')' {
      return i, i > 0
    }
    if !is_num(c) {
      return -1, false
    }
  }
  return 3, true
}

is_num :: proc(c: u8) -> bool {
  return c >= '0' && c <= '9'
}
