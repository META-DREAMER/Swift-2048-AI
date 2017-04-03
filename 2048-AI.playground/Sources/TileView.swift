import UIKit


extension UIColor {
    static let lightBeige = UIColor(red:0.93, green:0.89, blue:0.85, alpha:1.0)
    static let beige = UIColor(red:0.93, green:0.88, blue:0.78, alpha:1.0)
    static let lightOrange = UIColor(red:0.95, green:0.69, blue:0.47, alpha:1.0)
    static let orange = UIColor(red:0.96, green:0.58, blue:0.39, alpha:1.0)
    static let lightRed = UIColor(red:0.96, green:0.49, blue:0.37, alpha:1.0)
    static let red = UIColor(red:0.96, green:0.37, blue:0.23, alpha:1.0)
    static let gold = UIColor(red:0.93, green:0.80, blue:0.38, alpha:1.0)
    static let brown = UIColor(red:0.73, green:0.68, blue:0.63, alpha:1.0)
    static let green = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
}

class TileView : UIView {
    let label : UILabel

    var value : Int = 0 {
        didSet {
            backgroundColor = TileView.tileColors[value] ?? .gold
            label.textColor = value > 4 ? UIColor.white : UIColor.gray
            label.text = "\(value)"
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    static var tileColors : Dictionary<Int, UIColor> = [
        2: .lightBeige,
        4: .beige,
        8: .lightOrange,
        16: .orange,
        32: .lightRed,
        64: .red,
        128: .gold
    ]
    
    init(position: CGPoint, size: CGFloat, value v: Int) {
        self.value = v
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.label.text = "\(v)"
        self.label.textColor = v > 4 ? UIColor.white : UIColor.gray
        self.label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightHeavy)
        self.label.textAlignment = NSTextAlignment.center
        
        super.init(frame: CGRect(x: position.x, y: position.y, width: size, height: size))
        
        self.addSubview(label)
        self.layer.cornerRadius = 5.0
        self.backgroundColor = TileView.tileColors[v] ?? .gold
    }
}
