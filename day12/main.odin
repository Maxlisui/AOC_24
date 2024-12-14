package day12

import "core:fmt"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

input := #load("input.txt", string)

PlotMap :: struct {
  plants:  [dynamic]u8,
  visited: []b8,
  width:   int,
  height:  int,
}

get_visited :: proc(using plot_map: ^PlotMap, pos: Vector2) -> ^b8 {
  return &visited[pos.y * width + pos.x]
}

get_plant :: proc(using plot_map: PlotMap, pos: Vector2) -> u8 {
  return plants[pos.y * width + pos.x]
}

has_unvisited :: proc(visited: []b8) -> bool {
  for it in visited do if !it do return true
  return false
}

FenceSide :: enum {
  Top,
  Bottom,
  Left,
  Right,
}

FencePiece :: struct {
  side:      FenceSide,
  using pos: Vector2,
}

fence_piece_sort_len :: proc(it: sort.Interface) -> int {
  pieces := cast(^[dynamic]FencePiece)it.collection
  return len(pieces^)
}

fence_piece_sort_less :: proc(it: sort.Interface, i, j: int) -> bool {
  pieces := cast(^[dynamic]FencePiece)it.collection
  if pieces[i].y < pieces[j].y do return true
  if pieces[i].y > pieces[j].y do return false
  return pieces[i].x < pieces[j].x
}

fence_piece_sort_swap :: proc(it: sort.Interface, i, j: int) {
  pieces := cast(^[dynamic]FencePiece)it.collection
  slice.swap(pieces^[:], i, j)
}

RegionEdge :: struct {
  side:  FenceSide,
  start: Vector2,
  end:   Vector2,
}


Vector2 :: [2]int

main :: proc() {
  task1()
  task2()
}

task1 :: proc() {
  plot_map: PlotMap
  defer delete(plot_map.plants)

  input_mut := input
  for line in strings.split_lines_iterator(&input_mut) {
    for i in 0 ..< len(line) {
      append(&plot_map.plants, line[i])
    }
    assert(plot_map.width == 0 || len(line) == plot_map.width)
    plot_map.width = len(line)
    plot_map.height += 1
  }

  plot_map.visited = make([]b8, len(plot_map.plants))
  defer delete(plot_map.visited)

  total_cost := 0

  for has_unvisited(plot_map.visited) {
    region_plant: u8
    frontier: [dynamic]Vector2
    defer delete(frontier)

    for &visited, i in plot_map.visited {
      if !visited {
        region_plant = plot_map.plants[i]
        visited = true
        append(&frontier, Vector2{i % plot_map.width, i / plot_map.width})
        break
      }
    }

    region_area := 0
    region_perimeter := 0

    for len(frontier) > 0 {
      pos := pop(&frontier)
      assert(region_plant == get_plant(plot_map, pos))

      region_area += 1
      neighbors := []Vector2 {
        {pos.x - 1, pos.y},
        {pos.x + 1, pos.y},
        {pos.x, pos.y - 1},
        {pos.x, pos.y + 1},
      }
      for neighbor in neighbors {
        out_of_bounds :=
          neighbor.x < 0 ||
          neighbor.x >= plot_map.width ||
          neighbor.y < 0 ||
          neighbor.y >= plot_map.height
        if !out_of_bounds && get_plant(plot_map, neighbor) == region_plant {
          neighbor_visited := get_visited(&plot_map, neighbor)
          if !neighbor_visited^ {
            neighbor_visited^ = true
            append(&frontier, neighbor)
          }
        } else {
          region_perimeter += 1
        }
      }
    }

    region_cost := region_area * region_perimeter
    total_cost += region_cost
  }

  fmt.printfln("Total cost: %v", total_cost)
}

task2 :: proc() {
  plot_map: PlotMap
  defer delete(plot_map.plants)

  input_mut := input
  for line in strings.split_lines_iterator(&input_mut) {
    for i in 0 ..< len(line) do append(&plot_map.plants, line[i])
    assert(plot_map.width == 0 || len(line) == plot_map.width)
    plot_map.width = len(line)
    plot_map.height += 1
  }

  plot_map.visited = make([]b8, len(plot_map.plants))
  defer delete(plot_map.visited)

  total_cost := 0

  for has_unvisited(plot_map.visited) {
    region_plant: u8
    frontier: [dynamic]Vector2
    defer delete(frontier)

    for &visited, i in plot_map.visited {
      if !visited {
        region_plant = plot_map.plants[i]
        visited = true
        append(&frontier, Vector2{i % plot_map.width, i / plot_map.width})
        break
      }
    }

    region_area := 0
    region_fence_piece_set: map[FencePiece]u8
    defer delete(region_fence_piece_set)

    for len(frontier) > 0 {
      pos := pop(&frontier)
      visited := get_visited(&plot_map, pos)
      assert(visited^ == true, fmt.tprintf("region_plant: %v, pos: %v", region_plant, pos))
      assert(region_plant == get_plant(plot_map, pos))

      region_area += 1
      neighbors := []Vector2 {
        {pos.x - 1, pos.y},
        {pos.x + 1, pos.y},
        {pos.x, pos.y - 1},
        {pos.x, pos.y + 1},
      }
      for neighbor in neighbors {
        out_of_bounds :=
          neighbor.x < 0 ||
          neighbor.x >= plot_map.width ||
          neighbor.y < 0 ||
          neighbor.y >= plot_map.height
        if !out_of_bounds && get_plant(plot_map, neighbor) == region_plant {
          neighbor_visited := get_visited(&plot_map, neighbor)
          if !neighbor_visited^ {
            neighbor_visited^ = true
            append(&frontier, neighbor)
          }
        } else {
          fence_piece: FencePiece
          fence_piece.pos = pos
          switch neighbor.x {
          case pos.x - 1:
            fence_piece.side = .Left
          case pos.x + 1:
            fence_piece.side = .Right
          }
          switch neighbor.y {
          case pos.y - 1:
            fence_piece.side = .Top
          case pos.y + 1:
            fence_piece.side = .Bottom
          }
          region_fence_piece_set[fence_piece] = 1
        }
      }
    }

    region_fence_pieces: [dynamic]FencePiece
    defer delete(region_fence_pieces)

    for piece in region_fence_piece_set {
      append(&region_fence_pieces, piece)
    }


    sort.sort(
      sort.Interface {
        collection = &region_fence_pieces,
        len = fence_piece_sort_len,
        less = fence_piece_sort_less,
        swap = fence_piece_sort_swap,
      },
    )

    region_edges: [dynamic]RegionEdge
    defer delete(region_edges)

    piece_loop: for piece in region_fence_pieces {
      for &edge in region_edges {
        if piece.side != edge.side {
          continue
        }

        if piece.side == .Top || piece.side == .Bottom {
          if edge.start.y != piece.y {
            continue
          }

          if edge.start.x - 1 == piece.x {
            edge.start.x = piece.x
            continue piece_loop
          }
          if edge.end.x + 1 == piece.x {
            edge.end.x = piece.x
            continue piece_loop
          }
        } else {
          if edge.start.x != piece.x do continue

          if edge.start.y - 1 == piece.y {
            edge.start.y = piece.y
            continue piece_loop
          }
          if edge.end.y + 1 == piece.y {
            edge.end.y = piece.y
            continue piece_loop
          }
        }
      }
      append(&region_edges, RegionEdge{side = piece.side, start = piece.pos, end = piece.pos})
    }

    region_cost := region_area * len(region_edges)
    total_cost += region_cost
  }

  fmt.printfln("New total cost: %v", total_cost)
}
