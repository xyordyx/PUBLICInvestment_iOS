//
//  HistoryViewController.swift
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        self.tabBarController?.tabBar.isHidden = true
        historyTableView.dataSource = self
        historyTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryReusableCell")
        
        cig.getDebtorSummary(DataModel.shared.smartToken!, (opportunitie?.debtor?._id)!, "pen")
        cig.getDebtorSummary(DataModel.shared.smartToken!, (opportunitie?.debtor?._id)!, "usd")
        cig.getDebtorHistory((opportunitie?.debtor?._id)!,DataModel.shared.smartToken!)
        activityIndicator.startAnimating()
        activityView.isHidden = false
        
        self.activityIndicator.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        self.view.addSubview(activityIndicator)
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
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "HistoryReusableCell", for: indexPath) as! HistoryCell
        //LOGIC WERE REMOVED
            cell.amountLabel.text = util.doubleFormatter((debtorInvoices![indexPath.row]?.amountInvested!)!, 2)! + (debtorInvoices![indexPath.row]?.currency!)!
            cell.dateLabel.text = util.historyDateFormatter((debtorInvoices![indexPath.row]?.createdAt)!)
                
        }
        return cell
    }
    
}

extension HistoryViewController: CIGDebtorHistoryDelegate{
    func didUpdatDebtorHistory(_ cigManager: CIGDebtorHistory, _ debtorHistory: DebtorQuery) {
        self.debtorInvoices = debtorHistory.debtorInvoices
        if(debtorHistory.debtorInvoices.count != 0){
            historyTableView.backgroundView = nil
            self.debtorInvoices = self.debtorInvoices!.sorted(by: { ($0?.status!)! < ($1?.status!)!})
        }
        activityIndicator.stopAnimating()
        activityView.isHidden = true
        historyTableView.reloadData()

    }
    
    func didUpdatDebtorSummary(_ cigManager: CIGDebtorHistory, _ debtorSummary: DebtorHistory,_ currency: String) {
        //LOGIC WERE REMOVED
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
