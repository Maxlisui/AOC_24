package day1

import "core:fmt"
import "core:slice"
import "core:strconv"

input := #load("input.txt", string)

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  left := make([dynamic]int)
  defer delete(left)
  right := make([dynamic]int)
  defer delete(right)

  for i := 0; i < len(input); i += 1 {
    c := input[i]
    if c == '\n' || c == '\r' {
      continue
    }

    left_start := i
    for c >= '0' && c <= '9' {
      i += 1
      c = input[i]
    }

    left_num, ok_l := strconv.parse_int(input[left_start:i])
    assert(ok_l)

    for c == ' ' {
      i += 1
      c = input[i]
    }

    right_start := i
    for c >= '0' && c <= '9' {
      i += 1
      c = input[i]
    }

    right_num, ok_r := strconv.parse_int(input[right_start:i])
    if !ok_r {
      fmt.println(right_start)
      fmt.println(input[right_start:i])
    }
    assert(ok_r)

    append(&left, left_num)
    append(&right, right_num)
  }

  slice.sort(left[:])
  slice.sort(right[:])

  assert(len(left) == len(right))

  distance := 0
  for l, i in left {
    r := right[i]

    distance += abs(l - r)
  }

  fmt.printfln("Total distance: %v", distance)
}

task2 :: proc() {
  left := make([dynamic]int)
  defer delete(left)
  right := make(map[int]int)
  defer delete(right)

  for i := 0; i < len(input); i += 1 {
    c := input[i]
    if c == '\n' || c == '\r' {
      continue
    }

    left_start := i
    for c >= '0' && c <= '9' {
      i += 1
      c = input[i]
    }

    left_num, ok_l := strconv.parse_int(input[left_start:i])
    assert(ok_l)

    for c == ' ' {
      i += 1
      c = input[i]
    }

    right_start := i
    for c >= '0' && c <= '9' {
      i += 1
      c = input[i]
    }

    right_num, ok_r := strconv.parse_int(input[right_start:i])
    assert(ok_r)

    append(&left, left_num)

    if right_num in right {
      right[right_num] += 1
    } else {
      right[right_num] = 1
    }
  }

  similarity := 0
  for l in left {
    r := right[l]
    similarity += l * r
  }

  fmt.printfln("Similarity score: %v", similarity)
}
