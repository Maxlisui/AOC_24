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
  reports := make([dynamic][dynamic]int)
  defer {
    for r in reports {
      delete(r)
    }
    delete(reports)
  }

  current_report := make([dynamic]int)
  for i := 0; i < len(input); i += 1 {
    c := input[i]

    for {
      num_start := i
      for c >= '0' && c <= '9' {
        i += 1
        c = input[i]
      }

      num, ok := strconv.parse_int(input[num_start:i])
      assert(ok)

      append(&current_report, num)

      for c == ' ' || c == '\r' {
        i += 1
        c = input[i]
      }

      if c == '\n' {
        append(&reports, current_report)
        current_report = make([dynamic]int)
        break
      }
    }
  }

  num_safe := 0
  for report in reports {
    if is_report_safe(report[:]) {
      num_safe += 1
    }
  }

  fmt.printfln("Number of safe reports: %v", num_safe)
}

task2 :: proc() {
  reports := make([dynamic][dynamic]int)
  defer {
    for r in reports {
      delete(r)
    }
    delete(reports)
  }

  current_report := make([dynamic]int)
  for i := 0; i < len(input); i += 1 {
    c := input[i]

    for {
      num_start := i
      for c >= '0' && c <= '9' {
        i += 1
        c = input[i]
      }

      num, ok := strconv.parse_int(input[num_start:i])
      assert(ok)

      append(&current_report, num)

      for c == ' ' || c == '\r' {
        i += 1
        c = input[i]
      }

      if c == '\n' {
        append(&reports, current_report)
        current_report = make([dynamic]int)
        break
      }
    }
  }

  num_safe := 0
  for report in reports {
    if is_report_safe(report[:]) || is_report_safe_damped(report[:]) {
      num_safe += 1
    }
  }

  fmt.printfln("Number of safe reports, with Problem Dampener: %v", num_safe)
}


is_report_safe :: proc(report: []int, element_to_skip := -1) -> bool {
  order := 0

  end := len(report) - 1
  if element_to_skip == end {
    end = len(report) - 2
  }

  for i := 0; i < end; i += 1 {
    level := report[i]
    next := report[i + 1]

    if i == element_to_skip {
      continue
    } else if i + 1 == element_to_skip {
      next = report[i + 2]
    }


    if order == 0 {
      if level < next {
        order = 1
      } else if level > next {
        order = -1
      }
    } else if order == 1 && level > next {
      return false
    } else if order == -1 && level < next {
      return false
    }

    diff := abs(level - next)
    if diff < 1 || diff > 3 {
      return false
    }
  }
  return true
}

is_report_safe_damped :: proc(report: []int) -> bool {
  for to_skip := 0; to_skip < len(report); to_skip += 1 {
    if is_report_safe(report, to_skip) {
      return true
    }
  }
  return false
}
