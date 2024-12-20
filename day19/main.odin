package day19

import "core:fmt"
import "core:slice"
import "core:strings"

input := #load("input.txt", string)

FrontierElement :: struct {
  remainder: string,
  parent:    FrontierIndex,
}
FrontierIndex :: struct {
  frontier_elements: ^[dynamic]FrontierElement,
  value:             int,
}
get :: proc(using index: FrontierIndex) -> ^FrontierElement {
  if frontier_elements != nil {
    return &frontier_elements[value]
  }
  return nil
}

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  available_patterns: [dynamic]string
  defer delete(available_patterns)

  requested_designs: [dynamic]string
  defer delete(requested_designs)

  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    if len(line) == 0 {
      continue
    }

    if available_patterns == nil {
      pattern_it := line
      for pattern in strings.split_iterator(&pattern_it, ", ") {
        append(&available_patterns, pattern)
      }
    } else {
      append(&requested_designs, line)
    }
  }

  possible_designs := 0

  for design in requested_designs {
    remainders: [dynamic]string
    defer delete(remainders)
    append(&remainders, design)

    processed_remainders: map[string]struct {}
    defer delete(processed_remainders)

    for len(remainders) > 0 {
      slice.sort_by(remainders[:], proc(lhs, rhs: string) -> bool {return len(lhs) > len(rhs)})

      current_remainder := pop(&remainders)
      if current_remainder in processed_remainders {
        continue
      }
      processed_remainders[current_remainder] = {}

      if len(current_remainder) == 0 {
        possible_designs += 1
        break
      }

      for pattern in available_patterns {
        if strings.starts_with(current_remainder, pattern) {
          append(&remainders, current_remainder[len(pattern):])
        }
      }
    }
  }

  fmt.printfln("Number of designs: %v", possible_designs)
}

task2 :: proc() {
  available_patterns: [dynamic]string
  defer delete(available_patterns)

  requested_designs: [dynamic]string
  defer delete(requested_designs)

  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    if len(line) == 0 {
      continue
    }

    if available_patterns == nil {
      pattern_it := line
      for pattern in strings.split_iterator(&pattern_it, ", ") {
        append(&available_patterns, pattern)
      }
    } else {
      append(&requested_designs, line)
    }
  }

  solution_count := 0

  for design in requested_designs {

    frontier_elements: [dynamic]FrontierElement
    defer delete(frontier_elements)
    append(&frontier_elements, FrontierElement{design, {}})

    frontier: [dynamic]FrontierIndex
    defer delete(frontier)
    append(&frontier, FrontierIndex{&frontier_elements, 0})

    processed_remainders: map[string]int
    defer delete(processed_remainders)

    for len(frontier) > 0 {
      slice.sort_by(
        frontier[:],
        proc(lhs, rhs: FrontierIndex) -> bool {return(
            len(get(lhs).remainder) >
            len(get(rhs).remainder) \
          )},
      )

      current_index := pop(&frontier)
      current := get(current_index)
      if current.remainder in processed_remainders {
        value := processed_remainders[current.remainder]
        for it := get(current.parent); it != nil; it = get(it.parent) {
          processed_remainders[it.remainder] += value
        }
        continue
      }

      processed_remainders[current.remainder] = 0

      for pattern in available_patterns {
        if strings.starts_with(current.remainder, pattern) {
          remainder := current.remainder[len(pattern):]
          if len(remainder) == 0 {
            for it := current; it != nil; it = get(it.parent) {
              processed_remainders[it.remainder] += 1
            }
          } else {
            index := len(frontier_elements)
            append(&frontier_elements, FrontierElement{remainder, current_index})
            append(&frontier, FrontierIndex{&frontier_elements, index})
          }
        }
      }
    }

    solution_count += processed_remainders[design]
  }

  fmt.printfln("Number of solutions: %v", solution_count)
}
