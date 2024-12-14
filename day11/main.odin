package day11

import "core:fmt"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  result := solve(25)
  fmt.printfln("Number of stones after 25 blinks: %v", result)
}

task2 :: proc() {
  result := solve(75)
  fmt.printfln("Number of stones after 75 blinks: %v", result)
}

solve :: proc(n: int) -> int {
  numbers: map[int]int
  defer delete(numbers)

  number_split := strings.split(input, " ")
  defer delete(number_split)

  for number_str in number_split {
    number := strconv.atoi(number_str)
    count := numbers[number]
    numbers[number] = count + 1
  }

  str_buf: [100]u8

  next_numbers: map[int]int
  defer delete(next_numbers)

  for iteration in 0 ..< n {
    defer {
      clear(&numbers)
      for number in next_numbers do numbers[number] = next_numbers[number]
      clear(&next_numbers)
    }

    for old_number, old_count in numbers {
      num_str := strconv.itoa(str_buf[:], old_number)
      new_nums := []int{-1, -1}

      if old_number == 0 {
        new_nums[0] = 1
      } else if len(num_str) % 2 == 0 {
        new_nums[0] = strconv.atoi(num_str[:len(num_str) / 2])
        new_nums[1] = strconv.atoi(num_str[len(num_str) / 2:])
      } else {
        new_nums[0] = old_number * 2024
      }

      for num in new_nums {
        if num != -1 {
          new_count := next_numbers[num]
          next_numbers[num] = new_count + old_count
        }
      }
    }
  }

  total_count := 0
  for number, count in numbers {
    total_count += count
  }

  return total_count
}
