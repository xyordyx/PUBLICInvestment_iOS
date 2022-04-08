//
//  ViewController.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 15/11/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var oppsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var actualUSDLabel: UILabel!
    @IBOutlet weak var actualPENLabel: UILabel!
    @IBOutlet weak var usdActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var solesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pullImage: UIImageView!
    @IBOutlet weak var pullLabel: UILabel!
    @IBOutlet weak var usdAvailable: UILabel!
    @IBOutlet weak var penAvailable: UILabel!
    @IBOutlet weak var oppTableView: UITableView!
    var refreshControl: UIRefreshControl!
    let util = Util()
    var cig = CIGInit()
    var displayOpps = [String: Opportunities]()
    var loggedIn = false
    var fireLoggedIn = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        cig.delegate = self
        oppTableView.dataSource = self
        oppTableView.delegate = self
        oppTableView.separatorStyle = .none
        oppTableView.showsVerticalScrollIndicator = false
        
        oppTableView.register(UINib(nibName: "OpportunitiesCell", bundle: nil), forCellReuseIdentifier: "OpportunitiesReusableCell")
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        oppTableView.addSubview(refreshControl)
        
        penAvailable.isHidden = true
        usdAvailable.isHidden = true
        actualPENLabel.isHidden = true
        actualUSDLabel.isHidden = true
        
        self.oppsActivityIndicator.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        self.view.addSubview(oppsActivityIndicator)
        oppTableView.backgroundView = nil
        
        oppsActivityIndicator.startAnimating()
        usdActivityIndicator.startAnimating()
        solesActivityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reset UI
        pullImage.isHidden = true
        pullLabel.isHidden = true
        penAvailable.isHidden = true
        usdAvailable.isHidden = true
        actualPENLabel.isHidden = true
        actualUSDLabel.isHidden = true
        oppsActivityIndicator.isHidden = false
        usdActivityIndicator.startAnimating()
        solesActivityIndicator.startAnimating()
        oppsActivityIndicator.startAnimating()
        
        self.cig.getOpportunities(DataModel.shared.smartToken!, DataModel.shared.scheduledInvestmentsNum)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        DataModel.shared.opportunities.removeAll()
        oppTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    //MARK: - TableView Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        for opp in DataModel.shared.opportunities{
            if(!opp.value.isScheduled!){
                count+=1
                displayOpps[opp.key] = opp.value
            }
            else{
                displayOpps.removeValue(forKey: opp.key)
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = oppTableView.dequeueReusableCell(withIdentifier: "OpportunitiesReusableCell", for: indexPath) as! OpportunitiesCell
        if(!Array(displayOpps)[indexPath.row].value.isScheduled!){
            cell.supplierLabel?.numberOfLines = 0
            cell.invoiceID = Array(displayOpps)[indexPath.row].key
            cell.oppVIew.layer.cornerRadius = cell.oppVIew.frame.height / 9
            
            cell.supplierLabel?.text = Array(displayOpps)[indexPath.row].value.debtor?.companyName
            cell.daysLabel?.text = String(Array(displayOpps)[indexPath.row].value.toBeCollectedIn!)
            cell.dateLabel?.text = util.dateFormatter(Array(displayOpps)[indexPath.row].value.paymentDate!)
            cell.teaLabel?.text = util.doubleFormatter(Array(displayOpps)[indexPath.row].value.tea!,2)
            cell.temLabel?.text = util.doubleFormatter(Array(displayOpps)[indexPath.row].value.tem!,2)
            if let sale = Array(displayOpps)[indexPath.row].value.onSale{
                if(sale){
                    cell.amountLabel?.text = util.doubleFormatter(Array(displayOpps)[indexPath.row].value.availableBalanceAmount!,0)!+" "+Array(displayOpps)[indexPath.row].value.currency!
                }else{
                    cell.amountLabel?.text = util.doubleFormatter(Array(displayOpps)[indexPath.row].value.advanceAmount!,0)!+" "+Array(displayOpps)[indexPath.row].value.currency!
                }
            }
            cell.amountLabel?.adjustsFontSizeToFitWidth = true
            cell.amountLabel?.minimumScaleFactor = 0.5
            cell.ratingLabel?.text = Array(displayOpps)[indexPath.row].value.evaluation?.rating!
            if let confirming = Array(displayOpps)[indexPath.row].value.isConfirming{
                if(confirming){
                    cell.confirmingLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                    cell.confirmingLabel?.text = "C"
                }
                else{
                    cell.confirmingLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    cell.confirmingLabel?.text = "F"
                }
            }
        }
        
        
        /*cell.costView.layer.cornerRadius = cell.costView.frame.height / 12
         cell.datesView.layer.cornerRadius = cell.datesView.frame.height / 12
         cell.rateView.layer.cornerRadius = cell.rateView.frame.height / 4
         cell.confirmingView.layer.cornerRadius = cell.rateView.frame.height / 4
         cell.rateView.backgroundColor = util.getColorRate(Array(self.invoiceDict)[indexPath.row].value.opportunitie.evaluation?.rating)
         if Array(self.invoiceDict)[indexPath.row].value.opportunitie.isConfirming!{cell.confirmingView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
         cell.confirmingLabel?.text = "C"
         }else{cell.confirmingLabel?.text = "F"}*/
        
        return cell
    }
    
    //MARK: -  TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToOpp", sender: self)
        oppTableView.deselectRow(at: indexPath, animated: true)        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        let destinationVC = segue.destination as! OppViewController
        if let indexPath = oppTableView.indexPathForSelectedRow{
            let cell: OpportunitiesCell = oppTableView.cellForRow(at: indexPath)! as! OpportunitiesCell
            destinationVC.opportunitie = DataModel.shared.opportunities[cell.invoiceID]
        }
    }
}


extension ViewController: CIGInitDelegate{
    
    func didUpdateFinancialBalance(_ cigManager: CIGInit, _ finTran: FinancialData){
        DataModel.shared.financialStats.totalPENDeposited = finTran.totalPENDeposited
        DataModel.shared.financialStats.totalUSDDeposited = finTran.totalUSDDeposited
        DataModel.shared.financialStats.totalPENAvailable = finTran.totalPENAvailable
        DataModel.shared.financialStats.totalUSDAvailable = finTran.totalUSDAvailable
        DataModel.shared.financialStats.totalPENProfited = finTran.totalPENProfited
        DataModel.shared.financialStats.totalUSDProfited = finTran.totalUSDProfited
        DataModel.shared.financialStats.totalPENCurrentInvested = finTran.totalPENCurrentInvested
        DataModel.shared.financialStats.totalUSDCurrentInvested = finTran.totalUSDCurrentInvested
        DataModel.shared.financialStats.totalPENScheduled = finTran.totalPENScheduled
        DataModel.shared.financialStats.totalUSDScheduled = finTran.totalUSDScheduled
        penAvailable.text = "S/ "+util.doubleFormatter(DataModel.shared.financialStats.totalPENAvailable!,0)!
        usdAvailable.text = "$ "+util.doubleFormatter(DataModel.shared.financialStats.totalUSDAvailable!,0)!
        penAvailable.isHidden = false
        usdAvailable.isHidden = false
        solesActivityIndicator.stopAnimating()
        usdActivityIndicator.stopAnimating()
        oppTableView.reloadData()
    }
    
    func didUpdateOpportunities(_ cigManager: CIGInit, _ appData: APPData) {
        util.updateFinancialValues(appData.financialBalance!)
        //OPP
        if (appData.opportunities != nil){
            if(appData.opportunities!.count > 0){
                let oppDict = self.util.setInvoices(DataModel.shared,appData.opportunities!)
                DataModel.shared.opportunities = oppDict
                pullImage.isHidden = true
                pullLabel.isHidden = true
                oppsActivityIndicator.isHidden = true
                oppTableView.reloadData()
                refreshControl.endRefreshing()
                oppsActivityIndicator.stopAnimating()
            }else{
                pullImage.isHidden = false
                pullLabel.isHidden = false
                refreshControl.endRefreshing()
                oppsActivityIndicator.stopAnimating()
                oppsActivityIndicator.isHidden = true
            }

        }
        self.util.refreshBalance(penAvailable,actualPENLabel,usdAvailable, actualUSDLabel)
        solesActivityIndicator.stopAnimating()
        usdActivityIndicator.stopAnimating()
        oppTableView.reloadData()
    }
    
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    @objc func refresh(_ sender: Any) {
        self.cig.getOpportunities(DataModel.shared.smartToken!, DataModel.shared.scheduledInvestmentsNum)
    }
}
