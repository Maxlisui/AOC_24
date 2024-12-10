package day10

import "core:fmt"
import "core:strings"

input := #load("input.txt", string)

Vector2 :: [2]int
Path :: [10]Vector2

Map :: struct($T: typeid) {
  raw:           []T,
  width, height: int,
}

map_at :: proc {
  map_at_pos,
  map_at_coordinates,
}

map_at_pos :: proc(mmap: Map($T), pos: Vector2) -> T {
  return map_at_coordinates(mmap, pos.x, pos.y)
}

map_at_coordinates :: proc(mmap: Map($T), x, y: int) -> T {
  return mmap.raw[y * mmap.width + x]
}

map_at_ref :: proc(mmap: Map($T), x, y: int) -> ^T {
  return &mmap.raw[y * mmap.width + x]
}


main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  topo_map := parse_map()
  defer delete(topo_map.raw)

  peaks := make([dynamic]Vector2)
  defer delete(peaks)

  for y in 0 ..< topo_map.height {
    for x in 0 ..< topo_map.width {
      v := map_at(topo_map, x, y)
      if v == '9' {
        append(&peaks, Vector2{x, y})
      }
    }
  }

  raw_reachable_peaks := make([][]b8, len(topo_map.raw))
  defer {
    for peak in raw_reachable_peaks {
      delete(peak)
    }
    delete(raw_reachable_peaks)
  }

  for &peak in raw_reachable_peaks {
    peak = make([]b8, len(peaks))
  }

  reachable_peaks := Map([]b8) {
    raw    = raw_reachable_peaks,
    height = topo_map.height,
    width  = topo_map.width,
  }

  still_updating := true
  for still_updating {
    still_updating = false

    for y in 0 ..< topo_map.height {
      for x in 0 ..< topo_map.width {
        height := map_at(topo_map, x, y)
        reachables := map_at_ref(reachable_peaks, x, y)

        if height == '9' {
          for peak, i in peaks {
            if peak == {x, y} && add_reachable(reachables, i) {
              still_updating = true
              break
            }
          }
          continue
        }

        neighbors := []Vector2{{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}}
        for neighbor in neighbors {
          if neighbor_exists(neighbor, topo_map.width, topo_map.height) {
            neighbor_height := map_at(topo_map, neighbor.x, neighbor.y)
            if neighbor_height == height + 1 {
              neighbor_reachables := map_at(reachable_peaks, neighbor.x, neighbor.y)
              for neighbor_reachable, i in neighbor_reachables {
                if neighbor_reachable && add_reachable(reachables, i) {
                  still_updating = true
                }
              }
            }
          }
        }
      }
    }
  }

  total_score := 0
  for y in 0 ..< topo_map.height {
    for x in 0 ..< topo_map.width {
      height := map_at(topo_map, x, y)
      if height == '0' {
        for reachable in map_at(reachable_peaks, x, y) {
          if reachable {
            total_score += 1
          }
        }
      }
    }
  }

  fmt.printfln("Sum of score: %v", total_score)
}

task2 :: proc() {
  topo_map := parse_map()
  defer delete(topo_map.raw)


  complete_paths: [dynamic]Path
  defer delete(complete_paths)

  frontier: [dynamic]Path
  defer delete(frontier)

  for y in 0 ..< topo_map.height {
    for x in 0 ..< topo_map.width {
      height := map_at(topo_map, x, y)
      if height == '9' {
        path: Path
        path[0] = {x, y}
        for &pos in path[1:] do pos = {-1, -1}
        append(&frontier, path)
      }
    }
  }

  for len(frontier) > 0 {
    path := pop(&frontier)
    current_index: int
    for ; current_index < len(path); current_index += 1 {
      if path[current_index] == {-1, -1} {
        current_index -= 1
        break
      }
    }

    if current_index == len(path) {
      append(&complete_paths, path)
      continue
    }

    pos := path[current_index]
    height := map_at(topo_map, pos)
    neighbors := []Vector2 {
      {pos.x - 1, pos.y},
      {pos.x + 1, pos.y},
      {pos.x, pos.y - 1},
      {pos.x, pos.y + 1},
    }
    for neighbor in neighbors {
      if neighbor_exists(neighbor, topo_map.width, topo_map.height) {
        neighbor_height := map_at(topo_map, neighbor)
        if neighbor_height + 1 == height {
          neighbor_path := path
          neighbor_path[current_index + 1] = neighbor
          append(&frontier, neighbor_path)
        }
      }
    }
  }

  fmt.printfln("Sum of ratings: %v", len(complete_paths))
}

parse_map :: proc() -> Map(u8) {
  raw_map := make([dynamic]u8)

  lines := strings.split_lines(input)
  defer delete(lines)

  map_height: int
  map_width: int
  for line in lines {
    if len(line) > 0 {
      append(&raw_map, ..transmute([]u8)line)
      assert(map_width == 0 || len(line) == map_width)
      map_height += 1
      map_width = len(line)
    }
  }

  return Map(u8){raw = raw_map[:], height = map_height, width = map_width}
}

add_reachable :: proc(current: ^[]b8, new: int) -> bool {
  was_new := current[new]
  current[new] = true
  return !was_new
}

neighbor_exists :: proc(neighbor: Vector2, w, h: int) -> bool {
  return neighbor.x >= 0 && neighbor.x < w && neighbor.y >= 0 && neighbor.y < h
}
