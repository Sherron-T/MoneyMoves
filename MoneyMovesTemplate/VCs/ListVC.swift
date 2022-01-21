import UIKit
import CoreData

class ListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    var fetchedResults:[NSManagedObject] = []
    let formatter = DateFormatter()
    let formatter2 = NumberFormatter()
    var filter: String = "ShowAll"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchedResults = retrieveEntries()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Alert Controller",
            message: "Select category to filter",
            preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        controller.addAction(cancelAction)
        let showAllAction = UIAlertAction(
            title: "Show All",
            style: .default,
            handler: { [self](action) in
                self.filter = "ShowAll"
                fetchedResults = retrieveEntries()
                tableView.reloadData()
            })
        controller.addAction(showAllAction)
        let userCategories = defaults.object(forKey: "categories") as! [String]
        for category in userCategories {
            let newAction = UIAlertAction(
                title: category,
                style: .default,
                handler: { [self](action) in
                    self.filter = category
                    let predicate = NSPredicate(format: "category CONTAINS %@", filter)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
                    let sortDescriptors = [sectionSortDescriptor]
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Transaction")
                    request.predicate = predicate
                    request.sortDescriptors = sortDescriptors
                    var newResults:[NSManagedObject]? = nil
                    
                    do {
                        try newResults = context.fetch(request) as? [NSManagedObject]
                        fetchedResults = newResults!
                        tableView.reloadData()
                    } catch {
                        // If an error occurs
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                })
            controller.addAction(newAction)
        }
        present(controller, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResults = retrieveEntries()
        tableView.reloadData()
        formatter.dateFormat = "MM/dd/yy"
        formatter2.numberStyle = NumberFormatter.Style.currency
        changeDarkMode()
        filter = "ShowAll"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResults.count
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
    
    func changeDarkMode() {
        let darkModeSetting = defaults.bool(forKey: "darkMode")
        if darkModeSetting {
            self.overrideUserInterfaceStyle = .dark
        } else {
            self.overrideUserInterfaceStyle = .light
        }
    }
}
