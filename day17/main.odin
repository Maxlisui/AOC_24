package day17

import "base:runtime"
import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

Interpreter :: struct {
  program:         []u8,
  register_a:      int,
  register_b:      int,
  register_c:      int,
  instruction_ptr: int,
}

Op_Code :: enum {
  Adv,
  Bxl,
  Bst,
  Jnz,
  Bxc,
  Out,
  Bdv,
  Cdv,
}

current_op_code :: proc(using interpreter: ^Interpreter) -> (res: Op_Code, ok: bool) {
  if instruction_ptr < len(program) do return Op_Code(program[instruction_ptr]), true
  else do return {}, false
}

current_operand :: proc(using interpreter: ^Interpreter) -> u8 {
  return program[instruction_ptr + 1]
}

combo_operand :: proc(using interpreter: ^Interpreter, raw_operand: u8) -> int {
  switch raw_operand {
  case 0 ..= 3:
    return int(raw_operand)
  case 4:
    return register_a
  case 5:
    return register_b
  case 6:
    return register_c
  case 7:
    fmt.printfln("Encountered special value %v", raw_operand)
  }
  panic(fmt.tprintf("Failed to handle combo operand: %v", raw_operand))
}

execute_op :: proc(using interpreter: ^Interpreter, op_code: Op_Code, operand: u8) -> Maybe(u8) {
  switch op_code {
  case .Adv:
    register_a = register_a >> uint(combo_operand(interpreter, operand))
  case .Bdv:
    register_b = register_a >> uint(combo_operand(interpreter, operand))
  case .Cdv:
    register_c = register_a >> uint(combo_operand(interpreter, operand))
  case .Bxl:
    register_b ~= int(operand)
  case .Bst:
    register_b = combo_operand(interpreter, operand) % 8
  case .Jnz:
    if register_a != 0 do instruction_ptr = int(operand) - 2
  case .Bxc:
    register_b ~= register_c
  case .Out:
    return u8(combo_operand(interpreter, operand) % 8)
  }
  return nil
}

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  interpreter: Interpreter

  program: [dynamic]u8
  defer delete(program)

  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    if len(line) == 0 do continue

    key_value_it := line
    key := strings.split_iterator(&key_value_it, ": ") or_else panic(line)
    value := strings.split_iterator(&key_value_it, ": ") or_else panic(line)

    if strings.has_prefix(key, "Register") {
      register_value := strconv.atoi(value)
      switch key[len(key) - 1] {
      case 'A':
        interpreter.register_a = register_value
      case 'B':
        interpreter.register_b = register_value
      case 'C':
        interpreter.register_c = register_value
      case:
        panic(line)
      }
    } else if strings.compare(key, "Program") == 0 {
      for num_str in strings.split_iterator(&value, ",") {
        append(&program, u8(strconv.atoi(num_str)))
      }
    } else {
      panic(line)
    }
  }

  interpreter.program = program[:]

  output_str := strings.builder_make()
  defer strings.builder_destroy(&output_str)

  interpreter.instruction_ptr = 0

  for op_code in current_op_code(&interpreter) {
    operand := current_operand(&interpreter)
    output := execute_op(&interpreter, op_code, operand)
    if output != nil {
      fmt.sbprintf(&output_str, "%v,", output)
    }
    interpreter.instruction_ptr += 2
  }

  result := transmute(string)output_str.buf[:len(output_str.buf) - 1]

  fmt.printfln("Task 1 Result: %v", result)
}

task2 :: proc() {
  interpreter: Interpreter

  program: [dynamic]u8
  defer delete(program)

  line_it := input
  for line in strings.split_lines_iterator(&line_it) {
    if len(line) == 0 do continue

    key_value_it := line
    key := strings.split_iterator(&key_value_it, ": ") or_else panic(line)
    value := strings.split_iterator(&key_value_it, ": ") or_else panic(line)

    if strings.has_prefix(key, "Register") {
      register_value := strconv.atoi(value)
      switch key[len(key) - 1] {
      case 'A':
        interpreter.register_a = register_value
      case 'B':
        interpreter.register_b = register_value
      case 'C':
        interpreter.register_c = register_value
      case:
        panic(line)
      }
    } else if strings.compare(key, "Program") == 0 {
      for num_str in strings.split_iterator(&value, ",") {
        append(&program, u8(strconv.atoi(num_str)))
      }
    } else {
      panic(line)
    }
  }

  interpreter.program = program[:]

  output_values := make([]u8, len(interpreter.program))
  defer delete(output_values)

  register_a := 1_000_000_000_000
  for {

    interpreter.instruction_ptr = 0
    interpreter.register_a = register_a
    index := 0
    for op_code in current_op_code(&interpreter) {
      operand := current_operand(&interpreter)
      output := execute_op(&interpreter, op_code, operand)
      if output != nil {
        output_values[index] = output.?
        index += 1
      }
      interpreter.instruction_ptr += 2
    }

    if slice.equal(interpreter.program, output_values[:]) do break
    else do register_a += 1
  }

  fmt.printfln("Register A: %v", register_a)
}
