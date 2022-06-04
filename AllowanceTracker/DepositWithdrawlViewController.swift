//
//  DepositWithdrawlViewController.swift
//  AllowanceTracker
//
//  Created by Spud on 5/1/22.
//

import Foundation
import UIKit
import CoreData

protocol DepositWithdrawlViewControllerDelegate {
    var balance: Balance? { get set }
    var creatingWithdrawl: Bool { get }
    func didTapDoneButton()
}

/**
 * Deposit: Add to balance;
 * Withdrawl: Add purchase
 */
class DepositWithdrawlViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountTextView: UITextField!
    @IBOutlet var descriptionTextView: UITextField!
    @IBOutlet var doneButton: UIButton!

    @IBOutlet var descriptionHiddenHeightConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var doneButtonToDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet var doneButtonToAmountTopConstraint: NSLayoutConstraint!
    
    var delegate: DepositWithdrawlViewControllerDelegate?
    var container: NSPersistentContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let creatingWithdrawl = delegate?.creatingWithdrawl else {
            print("Couldn't get delegate")
            return
        }
        
        titleLabel.text = creatingWithdrawl ? "Add Purchase" : "Add to Balance"
        amountTextView.placeholder = creatingWithdrawl ? "Price" : "Amount"
        doneButton.setTitle(creatingWithdrawl ? "Add a Purchase" : "Add to Balance", for: .normal)
        
        // set up constraints
        descriptionHeightConstraint.priority = creatingWithdrawl ? .defaultHigh : .defaultLow
        descriptionHiddenHeightConstraint.priority = creatingWithdrawl ? .defaultLow : .defaultHigh
        
        doneButtonToAmountTopConstraint.priority = creatingWithdrawl ? .defaultLow : .defaultHigh
        doneButtonToDescriptionTopConstraint.priority = creatingWithdrawl ? .defaultHigh : .defaultLow
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        
        guard let context = container?.viewContext else {
            // show user error probably? idk
            print("there was a problem getting the context")
            return
        }
        
        guard let creatingWithdrawl = delegate?.creatingWithdrawl else {
            print("Couldn't get delegate")
            return
        }
        
        if creatingWithdrawl {
            if let price = amountTextView.text,
                let description = descriptionTextView.text {
                let purchase = Purchase(context: context)
                purchase.price = Double(price) ?? 0.0
                purchase.reasonDescription = description
                purchase.date = Date()
                purchase.uuid = UUID()
            }
            
            do {
                try context.save()
                print("saved")
                delegate?.didTapDoneButton()
            }
            catch {
                // Handle Error
                print("there was a problem saving purchase to the context")
            }
        } else {
            if let amount = amountTextView.text {
                delegate?.balance?.amount += Double(amount) ?? 0.0
                delegate?.balance?.lastKnownDate = Date()
                delegate?.didTapDoneButton()
            }
        }
        
        dismiss(animated: true)
    }
}
