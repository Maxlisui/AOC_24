package day7

import "core:fmt"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

Equation :: struct {
  result:   int,
  operands: []int,
}

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  equations := parse_equations()
  defer {
    for e in equations {
      delete(e.operands)
    }
    delete(equations)
  }

  result := calibration_result(equations, false)
  fmt.printfln("Calibration Result: %v", result)
}

task2 :: proc() {
  equations := parse_equations()
  defer {
    for e in equations {
      delete(e.operands)
    }
    delete(equations)
  }

  result := calibration_result(equations, true)
  fmt.printfln("Calibration Result, with concat: %v", result)
}

parse_equations :: proc() -> []Equation {
  lines := strings.split_lines(input)
  defer delete(lines)
  equations := make([]Equation, len(lines))

  for line, i in lines {
    if len(line) <= 1 {
      continue
    }

    parts := strings.split(line, ": ")
    defer delete(parts)

    result, result_ok := strconv.parse_int(parts[0])
    assert(result_ok)

    splitted_operands := strings.split(parts[1], " ")
    defer delete(splitted_operands)

    operands := make([]int, len(splitted_operands))

    for s, j in splitted_operands {
      if len(s) == 0 {
        continue
      }

      op, ok := strconv.parse_int(s)
      assert(ok)

      operands[j] = op
    }

    equations[i] = Equation {
      result   = result,
      operands = operands,
    }
  }

  return equations
}

calibration_result :: proc(equations: []Equation, allow_concat: bool = false) -> int {
  result := 0
  for equation in equations {
    if len(equation.operands) == 0 {
      continue
    }

    if is_solvable(equation.result, equation.operands[0], equation.operands[1:], allow_concat) {
      result += equation.result
    }

  }
  return result
}

is_solvable :: proc(
  expected_result: int,
  current_result: int,
  remaining_operands: []int,
  allow_concat: bool,
) -> bool {
  if len(remaining_operands) == 0 {
    return expected_result == current_result
  }

  if is_solvable(
    expected_result,
    current_result + remaining_operands[0],
    remaining_operands[1:],
    allow_concat,
  ) {
    return true
  } else if is_solvable(
    expected_result,
    current_result * remaining_operands[0],
    remaining_operands[1:],
    allow_concat,
  ) {
    return true
  } else if allow_concat {
    return is_solvable(
      expected_result,
      int_concat(current_result, remaining_operands[0]),
      remaining_operands[1:],
      allow_concat,
    )
  } else {
    return false
  }
}

int_concat :: proc(i1, i2: int) -> int {
  return strconv.atoi(fmt.tprintf("%d%d", i1, i2))
}
