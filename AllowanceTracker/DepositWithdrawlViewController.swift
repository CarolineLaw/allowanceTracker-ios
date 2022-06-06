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
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
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
        amountTextField.placeholder = creatingWithdrawl ? "Price" : "Amount"
        doneButton.setTitle(creatingWithdrawl ? "Add a Purchase" : "Add to Balance", for: .normal)
        
        // Accessibility
        titleLabel.accessibilityIdentifier = creatingWithdrawl ? "add_purchase_title_label_id" : "add_balance_title_label_id"
        amountTextField.accessibilityIdentifier = creatingWithdrawl ? "price_amount_text_field_id" : "balance_amount_text_field_id"
        doneButton.accessibilityIdentifier = creatingWithdrawl ? "purchase_done_button_id" : "balance_done_button_id"
        
        amountTextField.accessibilityHint = creatingWithdrawl ? "User enters purchase amount" : "User enters balance amount"
        doneButton.accessibilityHint = creatingWithdrawl ? "Dismisses purchase detail and adds purchase to list" : "Dismisses balance detail and adds amount to balance"
        
        
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
            if let price = amountTextField.text,
                let description = descriptionTextField.text {
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
            if let amount = amountTextField.text {
                delegate?.balance?.amount += Double(amount) ?? 0.0
                delegate?.balance?.lastKnownDate = Date()
                delegate?.didTapDoneButton()
            }
        }
        
        dismiss(animated: true)
    }
}
