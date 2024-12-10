package day9

import "core:fmt"
import "core:strings"

input := #load("input.txt", string)

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  block_layout := make([dynamic]int)
  defer delete(block_layout)

  for i in 0 ..< len(input) {
    char := input[i]
    if char < '0' || char > '9' {
      break
    }

    file_id := -1
    block_length := char - '0'

    if i % 2 == 0 {
      file_id = i / 2
    }

    for j in 0 ..< block_length {
      append(&block_layout, file_id)
    }
  }

  free_slot_index := 0
  used_slot_index := len(block_layout) - 1
  for ; used_slot_index > free_slot_index; used_slot_index -= 1 {
    used_slot := block_layout[used_slot_index]
    if used_slot == -1 do continue

    for ; free_slot_index < used_slot_index; free_slot_index += 1 {
      free_slot := block_layout[free_slot_index]
      if free_slot == -1 {
        block_layout[free_slot_index] = used_slot
        block_layout[used_slot_index] = -1
        break
      }
    }
  }

  checksum := 0
  for slot, i in block_layout {
    if slot == -1 {
      break
    }
    checksum += i * slot
  }

  fmt.printfln("Checksum: %v", checksum)
}

task2 :: proc() {
  block_layout := make([dynamic]int)
  defer delete(block_layout)

  empty_space := make([dynamic]int)
  defer delete(empty_space)

  for i in 0 ..< len(input) {
    char := input[i]
    if char < '0' || char > '9' {
      break
    }

    file_id := -1
    block_length := char - '0'

    if i % 2 == 0 {
      file_id = i / 2
    }

    for j in 0 ..< block_length {
      append(&block_layout, file_id)
      append(&empty_space, -1)
    }
  }

  for right_index := len(block_layout) - 1; right_index >= 0; {
    file_id := block_layout[right_index]
    if file_id == -1 {
      right_index -= 1
      continue
    }

    file_start := right_index + 1
    file_end := right_index + 1
    for ; right_index >= 0; right_index -= 1 {
      if block_layout[right_index] != file_id {
        file_start = right_index + 1
        break
      }
    }
    file_size := file_end - file_start

    gap := find_gap(block_layout[:file_start], file_size)
    if gap != nil {
      copy(gap, block_layout[file_start:][:file_size])
      copy(block_layout[file_start:][:file_size], empty_space[:file_size])
    }
  }

  checksum := 0
  for slot, i in block_layout {
    if slot != -1 do checksum += i * slot
  }

  fmt.printfln("Checksum with new method: %v", checksum)
}

find_gap :: proc(block_layout: []int, min_size: int) -> []int {
  for i := 0; i < len(block_layout); {
    if block_layout[i] != -1 {
      i += 1
      continue
    }

    gap_start := i
    for ; i < len(block_layout); i += 1 {
      if block_layout[i] != -1 {
        break
      }
    }
    gap_end := i

    gap_size := gap_end - gap_start
    if gap_size >= min_size {
      return block_layout[gap_start:][:min_size]
    }
  }
  return nil
}
