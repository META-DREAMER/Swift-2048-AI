import Foundation

func randomItem<T>(fromArray a: Array<T>) -> T {
    let index = Int(arc4random_uniform(UInt32(a.count)))
    return a[index]
}

enum Direction {
    case UP, DOWN, LEFT, RIGHT
    
    static var moves : [Direction] = [.UP, .DOWN, .LEFT, .RIGHT]
    
    static func randomMove() -> Direction {
        return randomItem(fromArray: Direction.moves)
    }
}

class Tile: Equatable {
    var position: Position
    var value: Int = 0
    var wasMerged: Bool = false
    var isEmpty: Bool {
        return value == 0
    }
    
    init(atPosition p: Position, withValue v: Int) {
        self.position = p
        self.value = v
    }
    
    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        return lhs.value == rhs.value
    }
}

typealias Board = [Array<Tile>]
typealias Position = (Int, Int)

protocol EngineProtocol : class {
    func scoreChanged(to: Int)
    func tileMoved(from: Position, to: Position, value: Int)
    func tileAdded(at: Position, value: Int)
}

class Engine {
    weak var delegate: EngineProtocol?
    let size: Int
    private(set) var board: Board
    private(set) var score: Int = 0 {
        didSet {
            delegate?.scoreChanged(to: score)
        }
    }
    
    static let stepDirection: Dictionary<Direction,(Int, Int)> = [
        .UP: (-1,0),
        .DOWN: (1,0),
        .LEFT: (0,-1),
        .RIGHT: (0,1)
    ]

    init(boardSize: Int, delegate: EngineProtocol?) {
        self.size = boardSize
        self.board = Engine.createEmptyBoard(size: boardSize)
        self.delegate = delegate
    }
    
    init(withBoard b: Board) {
        self.size = b.count
        self.board = Engine.cloneBoard(board: b)
    }
    
    func reset() {
        score = 0
        board = Engine.createEmptyBoard(size: self.size)
    }
    
    static func createEmptyBoard(size s: Int) -> Board {
        var board: [Array<Tile>] = []
        for i in 0..<s  {
            var row : [Tile] = []
            for j in 0..<s {
                row.append(Tile(atPosition: (i,j), withValue: 0))
            }
            board.append(row)
        }
        return board
    }
    
    static func cloneBoard(board b: Board) -> Board {
        var board: [Array<Tile>] = []
        for i in 0..<b.count {
            var row : [Tile] = []
            for j in 0..<b.count {
                row.append(Tile(atPosition: (i,j), withValue: b[i][j].value))
            }
            board.append(row)
        }
        return board
    }
    
    func addRandTile() {
        let tiles = availableTiles()
        
        if tiles.count > 0 {
            let tile = randomItem(fromArray: tiles)
            
            var value = 2
            if arc4random_uniform(10) == 9 {
                value = 4
            }
            tile.value = value
            delegate?.tileAdded(at: tile.position, value: tile.value)
        }
    }
    
    func nextTile(from: Tile, inDirection d: Direction) -> Tile? {
        let (startI, startJ) = from.position
        let (stepI, stepJ) = Engine.stepDirection[d]!
        let nextI = startI + stepI
        let nextJ = startJ + stepJ
        if (nextI >= 0 && nextI < size && nextJ >= 0 && nextJ < size) {
            return board[nextI][nextJ]
        }
        return nil
    }
    
    func findNextEmptyTile(from: Tile, inDirection d: Direction) -> Tile {
        var current = from
        var next = nextTile(from: current, inDirection: d)
        while next != nil && next!.isEmpty {
            current = next!
            next = nextTile(from: current, inDirection: d)
        }
        
        return current
    }
    
    func move(direction d: Direction) -> Bool {
        var traverseOrder = (Array(0..<size),Array(0..<size))
        if d == .RIGHT {
            traverseOrder.1.reverse()
        } else if d == .DOWN {
            traverseOrder.0.reverse()
        }
        
        var didMove = false
        
        for row in board {
            for tile in row {
                tile.wasMerged = false
            }
        }
        
        for rowI in 0..<size {
            for colJ in 0..<size {
                let i = traverseOrder.0[rowI]
                let j = traverseOrder.1[colJ]
                
                let currentTile = board[i][j]
                
                if currentTile.isEmpty {
                    continue
                }
                
                let nextEmptyTile = findNextEmptyTile(from: currentTile, inDirection: d)
                let nextTileTaken = nextTile(from: nextEmptyTile, inDirection: d)
                
                if (nextTileTaken != nil &&
                    nextTileTaken == currentTile &&
                    !nextTileTaken!.wasMerged)
                {
                    nextTileTaken?.value *= 2
                    nextTileTaken?.wasMerged = true
                    currentTile.value = 0
                    score += nextTileTaken!.value
                    delegate?.tileMoved(
                        from: currentTile.position,
                        to: nextTileTaken!.position,
                        value: nextTileTaken!.value
                    )
                    didMove = true
                } else if nextEmptyTile !== currentTile {
                    nextEmptyTile.value = currentTile.value
                    currentTile.value = 0
                    delegate?.tileMoved(
                        from: currentTile.position,
                        to: nextEmptyTile.position,
                        value: nextEmptyTile.value
                    )
                    didMove = true
                }
            }
        }
        
        if didMove {
            addRandTile()
        }
        
        return didMove
    }
    
    func hasSameTileToRight(position: Position) -> Bool {
        let (i, j) = position
        if j >= size - 1 {
            return false
        }
        
        return board[i][j] == board[i][j+1]
    }
    
    func hasSameTileBelow(position: Position) -> Bool {
        let (i, j) = position
        if i >= size - 1 {
            return false
        }
        
        return board[i][j] == board[i+1][j]
    }
    
    func isGameOver() -> Bool {
        for row in board {
            for tile in row {
                if tile.isEmpty {
                    return false
                }
                if (hasSameTileBelow(position: tile.position) ||
                    hasSameTileToRight(position: tile.position)) {
                    return false
                }
            }
        }
        return true
    }
    
    func availableTiles() -> [Tile] {
        var tiles = [Tile]()
        for row in board {
            for tile in row {
                if tile.isEmpty {
                    tiles.append(tile)
                }
            }
        }
        return tiles
    }
}

