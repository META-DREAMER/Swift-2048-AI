import PlaygroundSupport
import UIKit

let game = GameViewController(size: 4)

game.preferredContentSize = game.view.frame.size
PlaygroundPage.current.liveView = game
