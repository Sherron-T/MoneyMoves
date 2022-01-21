import UIKit
import CoreData

class PieChart: UIView {
    
    var datasetResults:[NSManagedObject] = []
    
    func total() -> Double{
        var totalCost: Double = 0
        for transaction in datasetResults{
            totalCost += transaction.value(forKey: "money") as! Double
        }
        let budgetTotal = Double(defaults.string(forKey: "userBudget") ?? "0")
        var percentage = totalCost / budgetTotal!
        if percentage > 1.0 {
            percentage = 1.0
        }
        return percentage
    }
    
    override func draw(_ rect: CGRect) {
        let background = UIBezierPath(ovalIn: rect)
        UIColor.systemGray.setFill()
        background.fill()
        let slicePath = UIBezierPath()
        let lineWidth: CGFloat = 8.0
        slicePath.lineWidth = lineWidth
        slicePath.move(to: CGPoint(
          x: bounds.width / 2,
          y: bounds.height / 2))
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        slicePath.addArc(withCenter: centerPoint, radius: bounds.width / 2, startAngle: -CGFloat.pi * 0.5, endAngle: -CGFloat.pi * 0.5 + .pi * 2 * total(), clockwise: true)
        let defaultColor = defaults.object(forKey: "defaultColor")
        if defaultColor == nil {
            let selectedColor = UIColor.systemBlue
            selectedColor.setFill()
        }
        else{
            let colorComponents = defaultColor! as! [CGFloat]
            let selectedColor = UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 1)
            selectedColor.setFill()
        }
        slicePath.fill()
    }
}
