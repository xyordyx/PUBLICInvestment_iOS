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
    @IBOutlet weak var investedRecentlyTableView: UITableView!
    
    @IBOutlet weak var activityRecentIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityRecentlyView: UIView!

    let util = Util()
    let cig = CIGScheduler()
    var scheduledInvoices: [InvestmentJSON]?
    var completedInvoices: [InvestmentJSON]?
  
    var tempInvoiceId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleReusableCell")
        scheduleTableView.showsVerticalScrollIndicator = false
        
        investedRecentlyTableView.dataSource = self
        investedRecentlyTableView.delegate = self
        investedRecentlyTableView.register(UINib(nibName: "InvestCompletedCell", bundle: nil), forCellReuseIdentifier: "InvestCompletedReusableCell")
        investedRecentlyTableView.showsVerticalScrollIndicator = false

        self.activityIndicator.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:250)
        self.view.addSubview(activityIndicator)
        
        scheduleTableView.layer.masksToBounds = true
        scheduleTableView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        scheduleTableView.layer.borderWidth = 1.0
        scheduleTableView.layer.cornerRadius = scheduleTableView.frame.height / 20
        
        self.activityRecentIndicator.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:595)
        self.view.addSubview(activityRecentIndicator)
        
        investedRecentlyTableView.layer.masksToBounds = true
        investedRecentlyTableView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        investedRecentlyTableView.layer.borderWidth = 1.0
        investedRecentlyTableView.layer.cornerRadius = investedRecentlyTableView.frame.height / 20
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        cig.getInvesmentsByCompleted(true)
        cig.getInvesmentsByCompleted(false)
        activityIndicator.startAnimating()
        scheduleTableView.backgroundView = nil
        scheduleTableView.reloadData()
        investedRecentlyTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == scheduleTableView{
            if(scheduledInvoices == nil || scheduledInvoices?.count == 0){
                return 0
            }else{
                return scheduledInvoices!.count
            }
        }else if tableView == investedRecentlyTableView{
            if(completedInvoices == nil || completedInvoices?.count == 0){
                return 0
            }else{
                return completedInvoices!.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == scheduleTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleReusableCell", for: indexPath) as! ScheduleCell
            cell.handImage.isHidden = true
            cell.amountLabel?.adjustsFontSizeToFitWidth = true
            cell.amountLabel?.minimumScaleFactor = 0.5
            cell.supplierLabel.text = scheduledInvoices![indexPath.row].debtorName
            //LOGIC WERE REMOVED
            return cell
        }else if tableView == investedRecentlyTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "InvestCompletedReusableCell", for: indexPath) as! InvestCompletedCell
            cell.amountLabel?.adjustsFontSizeToFitWidth = true
            cell.amountLabel?.minimumScaleFactor = 0.5
            cell.debtoLabel.text = completedInvoices![indexPath.row].debtorName
            //SUCCESS
            if(completedInvoices![indexPath.row].status){
                //AUTO ADJUSTED
                //LOGIC WERE REMOVED
            }
            else{
                //ERROR
                cell.wrongIcon.isHidden = false
                cell.imageIcon.isHidden = true
                cell.equalIcon.isHidden = true
                
                cell.messageLabel.isHidden = false
                cell.messageLabel.text = completedInvoices![indexPath.row].message

                //LOGIC WERE REMOVED
                
            }
            return cell
        }
        return UITableViewCell()
    }


    private func handleMoveToTrash(_ invoiceId: String,_ isComplete: Bool) {
        tempInvoiceId = invoiceId
        cig.cancelScheduleInvestment(tempInvoiceId, isComplete)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == scheduleTableView{        // Trash action
            let trash = UIContextualAction(style: .destructive,
                                           title: "Cancel") { [weak self] (action, view, completionHandler) in
                self?.handleMoveToTrash(self!.scheduledInvoices![indexPath.row].invoiceId, false)
                completionHandler(true)
            }
            trash.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [trash])
        }else if tableView == investedRecentlyTableView{
            let trash = UIContextualAction(style: .destructive,
                                           title: "Remove") { [weak self] (action, view, completionHandler) in
                self?.handleMoveToTrash(self!.completedInvoices![indexPath.row].invoiceId, true)
                completionHandler(true)
            }
            trash.backgroundColor = #colorLiteral(red: 0.1252301037, green: 0.415497601, blue: 1, alpha: 1)
            return UISwipeActionsConfiguration(actions: [trash])
        }
        return nil
    }
}


extension ScheduleViewController: CIGSchedulerDelegate{
    func didInvesmentByComplete(_ cigManager: CIGScheduler, _ data: [InvestmentJSON],_ isComplete: Bool) {
        if(isComplete){
            completedInvoices = util.getRemovedInvestments(data)
            activityRecentIndicator.stopAnimating()
            if(completedInvoices?.count == 0){
                let rect = CGRect(origin: CGPoint(x: 1200,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let messageLabel = UILabel(frame: rect)
                messageLabel.text = "All Investments were removed"
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center;
                messageLabel.font = UIFont(name: "Helvetica Neue", size: 16)
                messageLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                messageLabel.sizeToFit()
                investedRecentlyTableView.backgroundView = messageLabel
            }else{
                investedRecentlyTableView.backgroundView = nil
            }
            investedRecentlyTableView.reloadData()
        }else{
            scheduledInvoices = data
            activityIndicator.stopAnimating()
            if(scheduledInvoices?.count == 0){
                let rect = CGRect(origin: CGPoint(x: 1200,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let messageLabel = UILabel(frame: rect)
                messageLabel.text = "No invoices were scheduled at this time"
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center;
                messageLabel.font = UIFont(name: "Helvetica Neue", size: 16)
                messageLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                messageLabel.sizeToFit()
                scheduleTableView.backgroundView = messageLabel
            }else{
                scheduleTableView.backgroundView = nil
            }
            scheduleTableView.reloadData()
        }
    }
    
    func didScheduleGotCancelled(_ cigManager: CIGScheduler, _ data: [InvestmentJSON],_ isCompleted: Bool) {
        if(isCompleted){
            completedInvoices = util.getRemovedInvestments(data)
            investedRecentlyTableView.reloadData()
        }else{
            if(tempInvoiceId != ""){
                DataModel.shared.opportunities[tempInvoiceId]?.isScheduled = false
                scheduledInvoices = data
                scheduleTableView.reloadData()
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
