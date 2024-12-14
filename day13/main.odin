package day13

import "core:fmt"
import "core:math"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  total_cost := 0

  input_it_str := input
  for block in strings.split_iterator(&input_it_str, "\n\n") {
    button_a: [2]int
    button_b: [2]int
    prize: [2]int

    block_it_str := block
    for line in strings.split_lines_iterator(&block_it_str) {
      line_it_str := line
      id := strings.split_iterator(&line_it_str, ": ") or_else panic(line)

      value := [2]int{parse_value(&line_it_str, 'X', line), parse_value(&line_it_str, 'Y', line)}

      if strings.compare(id, "Button A") == 0 do button_a = value
      else if strings.compare(id, "Button B") == 0 do button_b = value
      else if strings.compare(id, "Prize") == 0 do prize = value
      else do panic(line)
    }

    a_first_cost := 0
    {
      a_count, b_count := calculate_count(button_a, button_b, prize)
      a_first_cost = a_count * 3 + b_count
    }
    b_first_cost := 0
    {
      b_count, a_count := calculate_count(button_b, button_a, prize)
      b_first_cost = a_count * 3 + b_count
    }

    if a_first_cost == 0 {
      total_cost += b_first_cost
    } else if b_first_cost == 0 {
      total_cost += a_first_cost
    } else {
      total_cost += min(a_first_cost, b_first_cost)
    }
  }

  fmt.printfln("Smallest cost: %v", total_cost)
}

task2 :: proc() {
  total_cost := 0

  input_it_str := input
  for block in strings.split_iterator(&input_it_str, "\n\n") {
    button_a: [2]int
    button_b: [2]int
    prize: [2]int

    block_it_str := block
    for line in strings.split_lines_iterator(&block_it_str) {
      line_it_str := line
      id := strings.split_iterator(&line_it_str, ": ") or_else panic(line)

      parse_value :: proc(it_str: ^string, id_char: u8, line: string) -> int {
        value_str := strings.split_iterator(it_str, ", ") or_else panic(line)
        assert(value_str[0] == id_char)
        return strconv.atoi(value_str[2:])
      }

      value := [2]int{parse_value(&line_it_str, 'X', line), parse_value(&line_it_str, 'Y', line)}

      if strings.compare(id, "Button A") == 0 do button_a = value
      else if strings.compare(id, "Button B") == 0 do button_b = value
      else if strings.compare(id, "Prize") == 0 do prize = value
      else do panic(line)
    }

    prize += 10000000000000

    calculate_count :: proc(button, other_button, prize: [2]int) -> (count, other_count: int) {
      target := [2]f64{f64(prize.x), f64(prize.y)}
      a_offset := f64(0)
      a_ratio := f64(button.y) / f64(button.x)
      b_ratio := f64(other_button.y) / f64(other_button.x)
      b_offset := target.y - b_ratio * target.x
      intersection: [2]f64
      intersection.x = b_offset / (a_ratio - b_ratio)
      intersection.y = b_offset + b_ratio * intersection.x

      a_length := intersection - a_offset
      b_length := target - intersection

      count = int(math.round(a_length.x)) / button.x
      other_count = int(math.round(b_length.x)) / other_button.x
      if count < 0 || other_count < 0 do return 0, 0
      if count * button + other_count * other_button != prize do return 0, 0
      return
    }

    a_first_cost := 0
    {
      a_count, b_count := calculate_count(button_a, button_b, prize)
      a_first_cost = a_count * 3 + b_count
    }
    b_first_cost := 0
    {
      b_count, a_count := calculate_count(button_b, button_a, prize)
      b_first_cost = a_count * 3 + b_count
    }

    if a_first_cost == 0 do total_cost += b_first_cost
    else if b_first_cost == 0 do total_cost += a_first_cost
    else do total_cost += min(a_first_cost, b_first_cost)
  }

  fmt.printfln("Smallest cost, with converted units: %v", total_cost)
}

calculate_count :: proc(button, other_button, prize: [2]int) -> (count, other_count: int) {
  remaining_prize := prize
  for count = 1; count <= 100; count += 1 {
    remaining_prize -= button
    other_count_vec := remaining_prize / other_button
    other_count = other_count_vec[0]
    if other_count > 100 do continue
    if remaining_prize % other_button != 0 do continue
    if other_count_vec[0] != other_count_vec[1] do continue
    return
  }
  return 0, 0
}


parse_value :: proc(it_str: ^string, id_char: u8, line: string) -> int {
  value_str := strings.split_iterator(it_str, ", ") or_else panic(line)
  assert(value_str[0] == id_char)
  return strconv.atoi(value_str[2:])
}
