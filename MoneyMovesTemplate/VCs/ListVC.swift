//
//  ListVC.swift
//  MoneyMoves
//
//  Created by Sherron Thomas on 10/4/21.
//

import UIKit
import CoreData

class ListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    var fetchedResults:[NSManagedObject] = []
    let formatter = DateFormatter()
    let formatter2 = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchedResults = retrieveEntries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResults = retrieveEntries()
        tableView.reloadData()
        formatter.dateFormat = "MM/dd/yy"
        formatter2.numberStyle = NumberFormatter.Style.currency
        changeDarkMode()
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
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Transaction")
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
