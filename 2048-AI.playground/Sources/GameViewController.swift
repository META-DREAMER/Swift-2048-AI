import UIKit

public class GameViewController : UIViewController, EngineProtocol {
    var size: Int = 4
    
    var boardView: BoardView?
    private(set) var game: Engine?

    var scoreView: UILabel?
    var score: Int = 0 {
        didSet {
            scoreView?.text = "Score: \(score)"
        }
    }
    var delaySlider: UISlider?
    var delay: Double = 0.0
    
    var intSlider: UISlider?
    var intelligence: Int = 50 {
        didSet {
            solver?.intelligence = intelligence
        }
    }
    
    var solver: Solver?
    var solverBtn: UIButton?
    var solverRunning: Bool = false {
        didSet {
            solverBtn?.backgroundColor = solverRunning ? .red : .green
            solverBtn?.setTitle(solverRunning ? "Stop AI" : "Start AI", for: .normal)
        }
    }
    
    public init(size s: Int) {
        self.size = s
        super.init(nibName: nil, bundle: nil)
        game = Engine(boardSize: size, delegate: self)
        solver = Solver(game: game!)
        solver?.intelligence = intelligence

        self.view.backgroundColor = UIColor.white
        
        let up = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.upCommand(_:)))
        up.numberOfTouchesRequired = 1
        up.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(up)
        
        let down = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.downCommand(_:)))
        down.numberOfTouchesRequired = 1
        down.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(down)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.leftCommand(_:)))
        left.numberOfTouchesRequired = 1
        left.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.rightCommand(_:)))
        right.numberOfTouchesRequired = 1
        right.direction = UISwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(right)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override public func viewDidLoad()  {
        super.viewDidLoad()
        let boardView = BoardView(size: self.size, width: 300)
        
        self.view.addSubview(boardView)
        self.boardView = boardView
        boardView.center = CGPoint(x: view.bounds.midX, y: 200)
        boardView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        let scoreView = UILabel()
        self.view.addSubview(scoreView)
        self.scoreView = scoreView
        scoreView.text = "Score: 0"
        scoreView.textColor = .brown
        scoreView.font = UIFont.boldSystemFont(ofSize: 30)
        scoreView.textAlignment = NSTextAlignment.center
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        scoreView.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 20).isActive = true
        scoreView.centerXAnchor.constraint(equalTo: boardView.centerXAnchor).isActive = true
        
        let intLabel = UILabel()
        self.view.addSubview(intLabel)
        intLabel.text = "Intelligence:"
        intLabel.textColor = .brown
        intLabel.font = UIFont.boldSystemFont(ofSize: 20)
        intLabel.translatesAutoresizingMaskIntoConstraints = false
        intLabel.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 40).isActive = true
        intLabel.leadingAnchor.constraint(equalTo: boardView.leadingAnchor).isActive = true
        
        let intSlider = UISlider()
        self.view.addSubview(intSlider)
        self.intSlider = intSlider
        intSlider.maximumValue = 100
        intSlider.minimumValue = 0
        intSlider.value = Float(intelligence)
        intSlider.tintColor = .brown
        intSlider.translatesAutoresizingMaskIntoConstraints = false
        intSlider.leadingAnchor.constraint(equalTo: boardView.leadingAnchor).isActive = true
        intSlider.trailingAnchor.constraint(equalTo: boardView.trailingAnchor).isActive = true
        intSlider.topAnchor.constraint(equalTo: intLabel.bottomAnchor, constant: 10).isActive = true
        intSlider.addTarget(self, action: #selector(self.intSliderDidChange(_:)), for: .valueChanged)
        
        let delayLabel = UILabel()
        self.view.addSubview(delayLabel)
        delayLabel.text = "Delay Per Move:"
        delayLabel.textColor = .brown
        delayLabel.font = UIFont.boldSystemFont(ofSize: 20)
        delayLabel.translatesAutoresizingMaskIntoConstraints = false
        delayLabel.topAnchor.constraint(equalTo: intSlider.bottomAnchor, constant: 20).isActive = true
        delayLabel.leadingAnchor.constraint(equalTo: boardView.leadingAnchor).isActive = true

        let delaySlider = UISlider()
        self.view.addSubview(delaySlider)
        self.delaySlider = delaySlider
        delaySlider.maximumValue = 1
        delaySlider.minimumValue = 0
        delaySlider.value = Float(delay)
        delaySlider.tintColor = .brown
        delaySlider.translatesAutoresizingMaskIntoConstraints = false
        delaySlider.leadingAnchor.constraint(equalTo: boardView.leadingAnchor).isActive = true
        delaySlider.trailingAnchor.constraint(equalTo: boardView.trailingAnchor).isActive = true
        delaySlider.topAnchor.constraint(equalTo: delayLabel.bottomAnchor, constant: 10).isActive = true
        delaySlider.addTarget(self, action: #selector(self.delaySliderDidChange(_:)), for: .valueChanged)

        
        let resetBtn = UIButton()
        self.view.addSubview(resetBtn)
        resetBtn.backgroundColor = .brown
        resetBtn.setTitle("Reset", for: .normal)
        resetBtn.setTitleColor(UIColor.white, for: .normal)
        resetBtn.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        resetBtn.layer.cornerRadius = 8.0
        resetBtn.addTarget(self, action: #selector(self.reset), for: .touchUpInside)
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.leadingAnchor.constraint(equalTo: boardView.leadingAnchor).isActive = true
        resetBtn.trailingAnchor.constraint(equalTo: boardView.centerXAnchor, constant: -5).isActive = true
        resetBtn.topAnchor.constraint(equalTo: delaySlider.bottomAnchor, constant: 40).isActive = true
        
        let solverBtn = UIButton()
        self.view.addSubview(solverBtn)
        self.solverBtn = solverBtn
        solverBtn.backgroundColor = .green
        solverBtn.setTitle("Start AI", for: .normal)
        solverBtn.setTitleColor(UIColor.white, for: .normal)
        solverBtn.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        solverBtn.layer.cornerRadius = 8.0
        solverBtn.addTarget(self, action: #selector(self.solveButtonDidPress), for: .touchUpInside)
        solverBtn.translatesAutoresizingMaskIntoConstraints = false
        solverBtn.leadingAnchor.constraint(equalTo: resetBtn.trailingAnchor, constant: 10).isActive = true
        solverBtn.trailingAnchor.constraint(equalTo: boardView.trailingAnchor).isActive = true
        solverBtn.topAnchor.constraint(equalTo: delaySlider.bottomAnchor, constant: 40).isActive = true

        
        game!.addRandTile()
        game!.addRandTile()
    }
    
    func reset() {
        solverRunning = false
        boardView!.reset()
        game!.reset()
        game!.addRandTile()
        game!.addRandTile()
    }
    

    func makeMove(direction d: Direction!) {
        _ = game!.move(direction: d)
        let isOver = game!.isGameOver()
        if isOver {
            solverRunning = false
        } else if solverRunning {
            makeSolverMove()
        }
    }
    
    func makeSolverMove() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            if self.solverRunning {
                let bestMove = self.solver!.findBestMove()
                self.makeMove(direction: bestMove)
            }
        }
    }
    
    func scoreChanged(to s: Int) {
        score = s
    }
    
    func intSliderDidChange(_ sender:UISlider!) {
        intelligence = Int(round(sender.value))
    }
    
    func delaySliderDidChange(_ sender:UISlider!) {
        delay = Double(sender.value)
    }
    
    func solveButtonDidPress(_ sender:UIButton!) {
        if (solverRunning) {
            solverRunning = false
        } else {
            solverRunning = true
            makeSolverMove()
        }
    }
    
    func tileMoved(from: Position, to: Position, value: Int) {
        boardView!.moveTile(from: from, to: to, value: value)
    }
    
    func tileAdded(at position: Position, value: Int) {
        boardView!.insertTile(at: position, value: value)
    }

    @objc(up:)
    func upCommand(_ r: UIGestureRecognizer!) {
        makeMove(direction: .UP)
    }
    
    @objc(down:)
    func downCommand(_ r: UIGestureRecognizer!) {
        makeMove(direction: .DOWN)
    }
    
    @objc(left:)
    func leftCommand(_ r: UIGestureRecognizer!) {
        makeMove(direction: .LEFT)
    }
    
    @objc(right:)
    func rightCommand(_ r: UIGestureRecognizer!) {
        makeMove(direction: .RIGHT)
    }
}
