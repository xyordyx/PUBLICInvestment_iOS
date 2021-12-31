//
//  ViewController.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 15/11/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
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
    var cigScheduler = CIGScheduler()
    var displayOpps = [String: Opportunities]()
    var loggedIn = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        cigScheduler.delegate = self
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
        
        usdActivityIndicator.startAnimating()
        solesActivityIndicator.startAnimating()
        
        cig.getToken(email: "giancarlomape@gmail.com", actualPassword: "Megash!t01")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(loggedIn){
            cigScheduler.getCurrentSchedule(DataModel.shared.token!)
        }
        navigationController?.isNavigationBarHidden = true
        oppTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //Amount Available pressed
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            //Haptic enabled
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
            
            penAvailable.isHidden = true
            usdAvailable.isHidden = true
            actualPENLabel.isHidden = true
            actualUSDLabel.isHidden = true
            
            usdActivityIndicator.startAnimating()
            solesActivityIndicator.startAnimating()
            balanceView.reloadInputViews()
            cig.updateFinancialBalance(DataModel.shared.token!)

        }
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
        if(count == 0){
            pullImage.isHidden = false
            pullLabel.isHidden = false
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
            cell.teaLabel?.text = util.doubleFormatter(Double(Array(displayOpps)[indexPath.row].value.tea!)!,2)
            cell.temLabel?.text = util.doubleFormatter(Double(Array(displayOpps)[indexPath.row].value.tem!)!,2)
            if let sale = Array(displayOpps)[indexPath.row].value.onSale{
                if(sale){
                    cell.amountLabel?.text = util.doubleFormatter(Double(Array(displayOpps)[indexPath.row].value.availableBalanceAmount!)!,0)!+" "+Array(displayOpps)[indexPath.row].value.currency!
                }else{
                    cell.amountLabel?.text = util.doubleFormatter(Double(Array(displayOpps)[indexPath.row].value.advanceAmount!)!,0)!+" "+Array(displayOpps)[indexPath.row].value.currency!
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
            destinationVC.penAvailableAmount = DataModel.shared.financialStats.totalPENDisplay ?? 0.00
            destinationVC.usdAvailableAmount = DataModel.shared.financialStats.totalUSDDisplay ?? 0.00
        }
    }
}

extension ViewController: CIGInitDelegate, CIGSchedulerDelegate{
    func didFinancialBalanceGotUpdate(_ cigManager: CIGInit, _ finTran: FinancialBalance) {
        DataModel.shared.financialStats.totalPENDeposited = finTran.totalPENDeposited
        DataModel.shared.financialStats.totalUSDDeposited = finTran.totalUSDDeposited
        DataModel.shared.financialStats.totalPENAvailable = finTran.totalPENAvailable
        DataModel.shared.financialStats.totalUSDAvailable = finTran.totalUSDAvailable
        DataModel.shared.financialStats.totalPENProfited = finTran.totalPENProfited
        DataModel.shared.financialStats.totalUSDProfited = finTran.totalUSDProfited
        DataModel.shared.financialStats.totalPENInProgress = finTran.totalPENInProgress
        DataModel.shared.financialStats.totalUSDInProgress = finTran.totalUSDInProgress
        penAvailable.isHidden = false
        usdAvailable.isHidden = false
        solesActivityIndicator.stopAnimating()
        usdActivityIndicator.stopAnimating()
        balanceView.reloadInputViews()
    }
    
    func didCurrentSchedule(_ cigManager: CIGScheduler, _ scheduledInvoices: [InvestmentJSON]) {
        if(scheduledInvoices.count != 0){
            let scheduleData = self.util.isScheduled(DataModel.shared.opportunities, scheduledInvoices)
            DataModel.shared.opportunities = scheduleData.opportunities
            if(scheduleData.amountPENScheduled > 0){
                DataModel.shared.financialStats.totalPENDisplay = DataModel.shared.financialStats.totalPENAvailable! -
                scheduleData.amountPENScheduled
                penAvailable.text = "S/ "+util.doubleFormatter((DataModel.shared.financialStats.totalPENDisplay!),0)!
                actualPENLabel.text = "Actual S/ "+util.doubleFormatter(DataModel.shared.financialStats.totalPENAvailable!,0)!
                actualPENLabel.isHidden = false
            }else{
                if let pen = DataModel.shared.financialStats.totalPENAvailable{
                    penAvailable.text = "S/ "+util.doubleFormatter(pen,0)!
                    DataModel.shared.financialStats.totalPENDisplay = pen
                    actualPENLabel.isHidden = true
                }
            }
            if(scheduleData.amountUSDScheduled > 0){
                DataModel.shared.financialStats.totalUSDDisplay = DataModel.shared.financialStats.totalUSDAvailable! -
                scheduleData.amountUSDScheduled
                usdAvailable.text = "$ "+util.doubleFormatter((DataModel.shared.financialStats.totalUSDDisplay!),0)!
                actualUSDLabel.text = "Actual $ "+util.doubleFormatter(DataModel.shared.financialStats.totalUSDAvailable!,0)!
                actualUSDLabel.isHidden = false
            }else{
                if let usd = DataModel.shared.financialStats.totalUSDAvailable{
                    usdAvailable.text = "S/ "+util.doubleFormatter(usd,0)!
                    DataModel.shared.financialStats.totalUSDDisplay = usd
                    actualUSDLabel.isHidden = true
                }
            }
        }else{
            if let pen = DataModel.shared.financialStats.totalPENAvailable{
                penAvailable.text = "S/ "+util.doubleFormatter(pen,0)!
                usdAvailable.text = "$ "+util.doubleFormatter(DataModel.shared.financialStats.totalUSDAvailable!,0)!
                DataModel.shared.financialStats.totalPENDisplay = pen
                DataModel.shared.financialStats.totalUSDDisplay = DataModel.shared.financialStats.totalUSDAvailable
            }
            actualUSDLabel.isHidden = true
            actualPENLabel.isHidden = true
        }
        oppTableView.reloadData()
    }
    
    func didUpdateOpportunities(_ cigManager: CIGInit, _ opps: [Opportunities]) {
        //OPP
        if opps.count != 0{
            let temp = self.util.setInvoices(DataModel.shared,opps)
            DataModel.shared.opportunities = temp
            pullImage.isHidden = true
            pullLabel.isHidden = true
            oppTableView.reloadData()
            refreshControl.endRefreshing()
        }
        //NO OPP
        else{
            pullImage.isHidden = false
            pullLabel.isHidden = false
            refreshControl.endRefreshing()
        }
    }
    
    func didUpdateFinancialBalance(_ cigManager: CIGInit, _ finTran: FinancialBalance){
        DataModel.shared.financialStats.totalPENDeposited = finTran.totalPENDeposited
        DataModel.shared.financialStats.totalUSDDeposited = finTran.totalUSDDeposited
        DataModel.shared.financialStats.totalPENAvailable = finTran.totalPENAvailable
        DataModel.shared.financialStats.totalUSDAvailable = finTran.totalUSDAvailable
        DataModel.shared.financialStats.totalPENProfited = finTran.totalPENProfited
        DataModel.shared.financialStats.totalUSDProfited = finTran.totalUSDProfited
        DataModel.shared.financialStats.totalPENInProgress = finTran.totalPENInProgress
        DataModel.shared.financialStats.totalUSDInProgress = finTran.totalUSDInProgress
        DataModel.shared.financialStats.totalPENDisplay = finTran.totalPENAvailable
        DataModel.shared.financialStats.totalUSDDisplay = finTran.totalUSDAvailable
        
        penAvailable.text = "S/ "+util.doubleFormatter(DataModel.shared.financialStats.totalPENAvailable!,0)!
        usdAvailable.text = "$ "+util.doubleFormatter(DataModel.shared.financialStats.totalUSDAvailable!,0)!
        penAvailable.isHidden = false
        usdAvailable.isHidden = false
        solesActivityIndicator.stopAnimating()
        usdActivityIndicator.stopAnimating()
        oppTableView.reloadData()
    }
    
    func didUpdateToken(_ cigManager: CIGInit, _ finsmartToken: String) {
        DispatchQueue.main.async {
            if finsmartToken != ""{
                DataModel.shared.token = finsmartToken
                self.cig.getOpportunities(finsmartToken)
                self.cig.getFinancialBalance(finsmartToken)
                self.loggedIn = true
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    @objc func refresh(_ sender: Any) {
        self.cig.getOpportunities(DataModel.shared.token!)
    }
    
    func didScheduleGotCancelled(_ cigManager: CIGScheduler, _ data: [InvestmentJSON],_ response: Int) {

    }
}
