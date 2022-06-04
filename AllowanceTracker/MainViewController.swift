//
//  ViewController.swift
//  AllowanceTracker
//
//  Created by Spud on 5/1/22.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var purchasesTableView: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    let defaults = UserDefaults.standard
    
    var container: NSPersistentContainer? = nil
    var purchases: [Purchase]?
    var balance: Balance?

    // Delegate property
    var creatingWithdrawl: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lastBalance: Data = defaults.object(forKey: "LastBalanceInput") as? Data {
            balance = try? JSONDecoder().decode(Balance.self, from: lastBalance)
        } else {
            balance = Balance(amount: 0.0, lastKnownDate: Date())
        }
        
        setBalanceLabel()
        
        purchasesTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        
        getPurchases()
        
    }
    
    func getPurchases() {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()

        let context = container?.viewContext
        purchases = try? context?.fetch(fetchRequest)
        
        if let purchases = purchases {
            emptyStateView.isHidden = !purchases.isEmpty
            purchasesTableView.isHidden = purchases.isEmpty
        }
    }
    
    func setBalanceLabel() {
        guard let balance = balance?.amount else {
            balanceLabel.text = "$0.00"
            return
        }
        
        balanceLabel.text = "$\(balance)"
    }
    
    @IBSegueAction func mainToDepositWithdrawlSegue(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> DepositWithdrawlViewController? {
        let viewController = DepositWithdrawlViewController(coder: coder)
        creatingWithdrawl = segueIdentifier == "mainToAddPurchaseSegue"
        
        viewController?.container = self.container
        viewController?.delegate = self
        
        viewController?.sheetPresentationController?.detents = creatingWithdrawl ? [.medium()] : [.large()]
        
        return viewController
    }
}

extension MainViewController: DepositWithdrawlViewControllerDelegate {
    func didTapDoneButton() {
        if creatingWithdrawl {
            getPurchases()
            
            purchasesTableView.reloadData()
            balance?.amount -= purchases?.last?.price ?? 0.0
        }
        
        if let encoded = try? JSONEncoder().encode(balance) {
            defaults.set(encoded, forKey: "LastBalanceInput")
        }
        
        setBalanceLabel()
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchases?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PurchaseTableViewCell = purchasesTableView.dequeueReusableCell(withIdentifier: "purchaseTableViewCellIdentifier", for: indexPath) as! PurchaseTableViewCell
        
        let purchase = purchases?[indexPath.row]
        guard let price = purchase?.price else {
            print("There was a problem getting the price")
            return UITableViewCell()
        }
        
        cell.titleLabel.text = purchase?.reasonDescription
        cell.rightDetail.text = "$\(price)"
        
        return cell
    }
}
