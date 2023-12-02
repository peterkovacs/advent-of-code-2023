
import ArgumentParser
import Parsing

/*
 Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
 Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
 Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
 Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
 Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
*/

struct Day2: ParsableCommand {
  struct Game {
    var red, green, blue: Int
  }

  enum Parser {
    static var parser =
      Parse {
        "Game ".utf8
        Int.parser()
        ": ".utf8

        // 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        Many {

          // 3 blue, 4 red
          Parse {
            Many(into: Game(red: 0, green: 0, blue: 0)) { game, output in
              game[keyPath: output.1] = output.0
            } element: {
              Parse {
                Int.parser()
                " ".utf8
                OneOf {
                  "red".utf8.map { \Game.red }
                  "green".utf8.map { \Game.green }
                  "blue".utf8.map { \Game.blue }
                }
              }
            } separator: {
              ", ".utf8
            }
          }

        } separator: {
          "; ".utf8
        } terminator: {
          End()
        }
      }
    }

  func run() throws {
    let games = try input.map(Parser.parser.parse)
    let part1 = games.filter { id, games in
      games.allSatisfy { game in
        game.red <= 12 &&
        game.green <= 13 &&
        game.blue <= 14
      }
    }.map(\.0).reduce(0, +)

    print("Part 1: ", part1)

    let part2 = games.map { _, games in
      games.map(\.red).max()! *
      games.map(\.green).max()! *
      games.map(\.blue).max()!
    }.reduce(0, +)

    print("Part 2: ", part2)
  }
}

