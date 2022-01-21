import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import CoreData

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var summaryTableView: UITableView!
    @IBOutlet weak var pieChart: PieChart!
    
    let ref = Database.database().reference()
    var fetchedResults:[NSManagedObject] = []
    let textCellIdentifier = "HomeCell"
    let formatter = DateFormatter()
    let formatter2 = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        summaryTableView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.welcomeLabel.text = "Hi \(defaults.string(forKey: "userName") ?? "")"
        changeDarkMode()
        fetchedResults = retrieveEntries()
        summaryTableView.reloadData()
        formatter.dateFormat = "MM/dd/yy"
        formatter2.numberStyle = NumberFormatter.Style.currency
        pieChart.setNeedsDisplay()
        pieChart.datasetResults = fetchedResults
    }
    
    func changeDarkMode() {
        let darkModeSetting = defaults.bool(forKey: "darkMode")
        if darkModeSetting {
            self.overrideUserInterfaceStyle = .dark
        } else {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = fetchedResults.count
        if rowCount > 5 {
            rowCount = 5
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! ListTableViewCell
        let row = indexPath.row
        let cellDate = fetchedResults[row].value(forKey: "date")
        let cellLabel = fetchedResults[row].value(forKey: "label")
        let cellMoney: Double = fetchedResults[row].value(forKey: "money") as! Double
        cell.dateLabel.text = formatter.string(from: cellDate as! Date)
        cell.labelLabel.text = (cellLabel as! String)
        cell.costLabel.text = formatter2.string(from: NSNumber(value: cellMoney))
        return cell
    }
    
    func retrieveEntries() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Transaction")
        request.sortDescriptors = sortDescriptors
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults)!
    }
}
