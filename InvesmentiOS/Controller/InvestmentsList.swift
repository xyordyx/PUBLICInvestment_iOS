//
//  InvestmentViewController.swift
//
//  Created by Martinez Giancarlo on 27/12/21.
//

import UIKit

class InvestmentsList: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var investmentTableView: UITableView!
    var debtorInvoices: [DebtorInvoices?]?
    var delayedNumberInvoices = 0
    var displayInvoices: [DebtorInvoices?]?
    let cig = CIGInvestments()
    let util = Util()
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        investmentTableView.dataSource = self
        investmentTableView.delegate = self
        investmentTableView.register(UINib(nibName: "InvestmentsCell", bundle: nil), forCellReuseIdentifier: "InvestmentsReusableCell")
        
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["All", "Delayed","Close to Pay"]
        cig.getCurrentInvestments(DataModel.shared.smartToken!)
        
        activityIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if(displayInvoices != nil){
            count = displayInvoices!.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvestmentsReusableCell", for: indexPath) as! InvestmentsCell
        cell.debtorLabel.adjustsFontSizeToFitWidth = true
        cell.debtorLabel.minimumScaleFactor = 0.5
        
        //LOGIC WERE REMOVED
        cell.investmentAmountLabel.text = util.doubleFormatter((displayInvoices![indexPath.row]?.amountInvested!)!, 2)!
        cell.profitLabel.text = util.doubleFormatter((displayInvoices![indexPath.row]?.expectedProfit!)!, 2)! + (debtorInvoices![indexPath.row]?.currency!)!
        cell.rucLabel.text = displayInvoices![indexPath.row]?.debtor?.companyRuc
        return cell
    }
    
    
}

extension InvestmentsList: UISearchBarDelegate, CIGInvestmentsDelegate{
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateInvestments(_ cigManager: CIGInvestments, _ investments: DebtorQuery) {
        self.debtorInvoices = investments.debtorInvoices.sorted(by: { ($0?.createdAt!)! > ($1?.createdAt!)!})
        self.delayedNumberInvoices = investments.delayedInvoices!
        let temp = self.debtorInvoices!.count - self.delayedNumberInvoices
        searchBar.scopeButtonTitles = ["All (\(self.debtorInvoices!.count))", "Delayed (\(self.delayedNumberInvoices))",
                                       "Close to Pay (\(temp))"]
        
        self.displayInvoices = self.debtorInvoices
        activityIndicator.stopAnimating()
        investmentTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            self.displayInvoices = self.debtorInvoices
        }else{
            self.displayInvoices = util.getDebtorInvoices(self.debtorInvoices!, searchBar.text!)
        }
        investmentTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.displayInvoices = util.getDebtorInvoices(self.debtorInvoices!, searchBar.text!)
        investmentTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if(selectedScope == 0){
            self.displayInvoices = self.debtorInvoices
            investmentTableView.reloadData()
        }
        else if(selectedScope == 1){
            self.displayInvoices = util.getDelayedInvoices(self.debtorInvoices!)
            investmentTableView.reloadData()
        }
        else if(selectedScope == 2){
            self.displayInvoices = util.getCloseToPayInvoices(self.debtorInvoices!)
            investmentTableView.reloadData()
        }
    }
    
    
}
