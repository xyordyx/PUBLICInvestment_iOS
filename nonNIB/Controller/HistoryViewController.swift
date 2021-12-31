//
//  HistoryViewController.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 19/11/21.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var invoiceFinalizedUSD: UILabel!
    @IBOutlet weak var invoiceFinalizedPEN: UILabel!
    @IBOutlet weak var amountFinalizaedUSD: UILabel!
    @IBOutlet weak var amountFinalizaedPEN: UILabel!
    @IBOutlet weak var amountProfitedUSD: UILabel!
    @IBOutlet weak var amountProfitedPEN: UILabel!
    @IBOutlet weak var invoicesUSD: UILabel!
    @IBOutlet weak var invoicesPEN: UILabel!
    @IBOutlet weak var amountInvestedPEN: UILabel!
    @IBOutlet weak var amountInvestedUSD: UILabel!
    
    var cig = CIGDebtorHistory()
    var opportunitie: Opportunities?
    var debtorInvoices: [DebtorInvoices?]?
    let util = Util()

    @IBOutlet weak var historyTableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        historyTableView.backgroundView = nil
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        self.tabBarController?.tabBar.isHidden = true
        historyTableView.dataSource = self
        historyTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryReusableCell")
        
        cig.getDebtorSummary(DataModel.shared.token!, (opportunitie?.debtor?._id)!, "pen")
        cig.getDebtorSummary(DataModel.shared.token!, (opportunitie?.debtor?._id)!, "usd")
        cig.getDebtorHistory((opportunitie?.debtor?._id)!,DataModel.shared.token!)
        historyTableView.backgroundView = nil
    }
}

extension HistoryViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if(debtorInvoices != nil){
            count = debtorInvoices!.count
            historyTableView.backgroundView = nil
        }
        if(count == 0){
            let rect = CGRect(origin: CGPoint(x: 1200,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.text = "No investments were made with this debtor"
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "Helvetica Neue", size: 16)
            messageLabel.sizeToFit()
            historyTableView.backgroundView = messageLabel
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "HistoryReusableCell", for: indexPath) as! HistoryCell
        if(debtorInvoices![indexPath.row]?.status == "finalized"){
            cell.stateLabel.text = "Completed"
            cell.temLabel.text = util.doubleFormatter((debtorInvoices![indexPath.row]?.tem!)!, 2)
            cell.profitLabel.text = util.doubleFormatter((debtorInvoices![indexPath.row]?.profitedAmount!)!, 2)
            if let dueDays = debtorInvoices![indexPath.row]?.pastDueDays{cell.dueDaysLabel.text = String(dueDays)}
            cell.remainingLabel.text = "-"
            cell.amountLabel.text = util.doubleFormatter((debtorInvoices![indexPath.row]?.amountInvested!)!, 2)!
            + (debtorInvoices![indexPath.row]?.currency!)!
            cell.dateLabel.text = util.historyDateFormatter((debtorInvoices![indexPath.row]?.createdAt)!)
            
        }else{
            cell.stateLabel.text = "In Progress"
            cell.temLabel.text = util.doubleFormatter((debtorInvoices![indexPath.row]?.tem!)!, 2)
            cell.profitLabel.text = "-"
            cell.dueDaysLabel.text = "-"
            if let remainingDays = debtorInvoices![indexPath.row]?.moraDays{
                if let toBecollected = debtorInvoices![indexPath.row]?.toBeCollectedIn{
                    if (toBecollected == "En mora"){
                        cell.remainingLabel.text = String(remainingDays*(-1))
                    }else{
                        cell.remainingLabel.text = String(remainingDays)
                    }
                }
            }
            cell.amountLabel.text = util.doubleFormatter((debtorInvoices![indexPath.row]?.amountInvested!)!, 2)! + (debtorInvoices![indexPath.row]?.currency!)!
            cell.dateLabel.text = util.historyDateFormatter((debtorInvoices![indexPath.row]?.createdAt)!)
                
        }
        return cell
    }
    
}

extension HistoryViewController: CIGDebtorHistoryDelegate{
    func didUpdatDebtorHistory(_ cigManager: CIGDebtorHistory, _ debtorHistory: DebtorQuery) {
        self.debtorInvoices = debtorHistory.debtorInvoices
        self.debtorInvoices = self.debtorInvoices!.sorted(by: { ($0?.status!)! < ($1?.status!)!})
        historyTableView.reloadData()

    }
    
    func didUpdatDebtorSummary(_ cigManager: CIGDebtorHistory, _ debtorSummary: DebtorHistory,_ currency: String) {
        if(currency == "pen"){
            amountInvestedPEN.text = debtorSummary.totalAmountAwaitingCollection
            invoicesPEN.text = String(debtorSummary.totalInvoicesAwaitingCollectionCount!)
            amountProfitedPEN.text = debtorSummary.investmentReturned
            amountFinalizaedPEN.text = debtorSummary.amountFinalized
            invoiceFinalizedPEN.text = String(debtorSummary.finalizedInvoicesCount!)
        }else{
            amountInvestedUSD.text = debtorSummary.totalAmountAwaitingCollection
            invoicesUSD.text = String(debtorSummary.totalInvoicesAwaitingCollectionCount!)
            amountProfitedUSD.text = debtorSummary.investmentReturned
            amountFinalizaedUSD.text = debtorSummary.amountFinalized
            invoiceFinalizedUSD.text = String(debtorSummary.finalizedInvoicesCount!)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
