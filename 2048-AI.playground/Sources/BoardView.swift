import UIKit

class BoardView : UIView {
    var size: Int = 4
    var tileSize: CGFloat = 55.0
    var padding: CGFloat = 6.0
    var tiles: Dictionary<IndexPath, TileView>
    let animationDuration: TimeInterval = 0.08
    
    init(size s: Int, width: CGFloat) {
        size = s
        tiles = Dictionary()
        padding = size > 6 ? 4.0 : padding
        tileSize = (width - padding * CGFloat(size + 1)) / CGFloat(size)

        super.init(frame: CGRect(x: 0, y: 0, width: width, height: width))
        self.layer.cornerRadius = 8.0
        self.backgroundColor = .brown
        var xCursor = padding
        var yCursor: CGFloat
        for _ in 0..<size {
            yCursor = padding
            for _ in 0..<size {
                let background = UIView(frame: CGRect(x: xCursor, y: yCursor, width: tileSize, height: tileSize))
                background.layer.cornerRadius = 5.0
                background.backgroundColor = UIColor.init(white: 1.0, alpha: 0.2)
                addSubview(background)
                yCursor += padding + tileSize
            }
            xCursor += padding + tileSize
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    func reset() {
        for (_, tile) in tiles {
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepingCapacity: true)
    }
    
    func insertTile(at pos: Position, value: Int) {
        let (i, j) = pos
        let y = padding + CGFloat(i)*(tileSize + padding)
        let x = padding + CGFloat(j)*(tileSize + padding)
        let tile = TileView(position: CGPoint(x: x, y: y), size: tileSize, value: value)
        tile.layer.setAffineTransform(CGAffineTransform(scaleX: 0, y: 0))
        
        addSubview(tile)
        bringSubview(toFront: tile)
        tiles[IndexPath(row: i, section: j)] = tile
        
        UIView.animate(withDuration: animationDuration * 3.0, delay: 0.0, options: .curveEaseOut,
                       animations: {
                        tile.layer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
        })
    }
    
    func moveTile(from: Position, to: Position, value: Int) {
        let fromIndex = IndexPath(row: from.0, section: from.1)
        let toIndex = IndexPath(row: to.0, section: to.1)
        
        let tile = tiles[fromIndex]
        let endTile = tiles[toIndex]
        
        var finalFrame = tile!.frame
        finalFrame.origin.x = padding + CGFloat(to.1)*(tileSize + padding)
        finalFrame.origin.y = padding + CGFloat(to.0)*(tileSize + padding)
        
        tiles.removeValue(forKey: fromIndex)
        tiles[toIndex] = tile
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: { tile!.frame = finalFrame },
                       completion: {(Bool) -> Void in
                        tile!.value = value
                        endTile?.removeFromSuperview()
        })
    }
}
