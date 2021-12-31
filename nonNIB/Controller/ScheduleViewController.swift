//
//  ScheduleViewController.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 19/11/21.
//

import UIKit
import SwipeCellKit
class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var scheduleTableView: UITableView!
    let amountBigger = "INVESTMENTS.INVESTMENT_AMOUNT_IS_BIGGER_THAN_TARGET_INVOICE_AVAILABLE_BALANCE"
    let amountZero = "AMOUNT AVAILABLE IS 0.00"
    let investmentClosed = "INVESTMENTS.TARGET_INVOICE_STATUS_DOESNT_ALLOW_NEW_INVESTMENTS"

    let util = Util()
    let cig = CIGScheduler()
    var scheduledInvoices = [String : InvestmentJSON]()
  
    var tempInvoiceId : String = ""
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleReusableCell")
        
        scheduleTableView.separatorStyle = .none
        scheduleTableView.showsVerticalScrollIndicator = false
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        self.refreshControl.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        self.activityIndicator.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        self.view.addSubview(activityIndicator)
        
        scheduleTableView.addSubview(refreshControl)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        cig.getCurrentSchedule(DataModel.shared.token!)
        activityIndicator.startAnimating()
        scheduleTableView.backgroundView = nil
        scheduleTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(scheduledInvoices.count == 0){
            return 0
        }else {
            return scheduledInvoices.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleReusableCell", for: indexPath) as! ScheduleCell
        cell.supplierLabel?.numberOfLines = 0
        cell.scheduleViewCell.layer.cornerRadius = cell.scheduleViewCell.frame.height / 9
        cell.amountLabel?.adjustsFontSizeToFitWidth = true
        cell.amountLabel?.minimumScaleFactor = 0.5
                
        cell.messageLabel.isHidden = true
        
        if(Array(scheduledInvoices)[indexPath.row].value.completed){
            //Invested
            if(Array(scheduledInvoices)[indexPath.row].value.status!){
                if(Array(scheduledInvoices)[indexPath.row].value.autoAdjusted){
                    cell.originalAmountLabel.isHidden = false
                    cell.originalAmountLabel.text = "Inital: "+util.doubleFormatter(Array(scheduledInvoices)[indexPath.row].value.amount,0)!
                    cell.amountLabel.text = util.doubleFormatter(Array(scheduledInvoices)[indexPath.row].value.adjustedAmount,0)! + Array(scheduledInvoices)[indexPath.row].value.currency
                }else{
                    cell.originalAmountLabel.isHidden = true
                    cell.amountLabel.text = util.doubleFormatter(Array(scheduledInvoices)[indexPath.row].value.amount,0)! + Array(scheduledInvoices)[indexPath.row].value.currency
                }
                cell.statusLabel.text = "Invested!"
            }
            //Error at investment
            else{
                if(Array(scheduledInvoices)[indexPath.row].value.message == amountBigger){
                    cell.messageLabel.text = "Amount is bigger"
                }else if(Array(scheduledInvoices)[indexPath.row].value.message == amountZero){
                    cell.messageLabel.text = "Amount available is 0.0"
                }else if(Array(scheduledInvoices)[indexPath.row].value.message == investmentClosed){
                    cell.messageLabel.text = "Invoice doesn't allow investments"
                }else{
                    cell.messageLabel.text = Array(scheduledInvoices)[indexPath.row].value.message
                }
                cell.statusLabel.text = "Failed"
                cell.messageLabel.isHidden = false
                cell.originalAmountLabel.isHidden = true
                cell.amountLabel.isHidden = true
            }
        }else{
            cell.statusLabel.text = "Scheduled"
            cell.amountLabel.text = util.doubleFormatter(Array(scheduledInvoices)[indexPath.row].value.amount,0)! + Array(scheduledInvoices)[indexPath.row].value.currency
            cell.originalAmountLabel.isHidden = true
        }
        cell.supplierLabel.text = Array(scheduledInvoices)[indexPath.row].value.debtorName
        if(Array(scheduledInvoices)[indexPath.row].value.time == 0){
            cell.timeLabel.text = "12:30"
        }else{
            cell.timeLabel.text = "5:30"
        }
        return cell
    }
    
    private func handleMoveToTrash(_ invoiceId: String) {
        tempInvoiceId = invoiceId
        cig.cancelScheduleInvestment(tempInvoiceId)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "Cancel") { [weak self] (action, view, completionHandler) in
            self?.handleMoveToTrash(Array(self!.scheduledInvoices)[indexPath.row].key)
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed
    
        
        let configuration = UISwipeActionsConfiguration(actions: [trash])
               //configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}


extension ScheduleViewController: CIGSchedulerDelegate{
    func didScheduleGotCancelled(_ cigManager: CIGScheduler, _ data: [InvestmentJSON],_ response: Int) {
        if(tempInvoiceId != ""){
            DataModel.shared.opportunities[tempInvoiceId]?.isScheduled = false
            
            scheduledInvoices = self.util.setScheduled(data)
            scheduleTableView.reloadData()
        }
    }
    
    func didCurrentSchedule(_ cigManager: CIGScheduler, _ data: [InvestmentJSON]) {
        scheduledInvoices = self.util.setScheduled(data)
        activityIndicator.stopAnimating()
        if(scheduledInvoices.count == 0){
            let rect = CGRect(origin: CGPoint(x: 1200,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.text = "No invoices were scheduled at this time"
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "Helvetica Neue", size: 23)
            messageLabel.sizeToFit()
            scheduleTableView.backgroundView = messageLabel
        }else{
            scheduleTableView.backgroundView = nil
        }
        refreshControl.endRefreshing()
        scheduleTableView.reloadData()
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    @objc func refresh(_ sender: Any) {
        scheduleTableView.backgroundView = nil
        scheduleTableView.reloadData()
        self.cig.getCurrentSchedule(DataModel.shared.token!)
    }
}
