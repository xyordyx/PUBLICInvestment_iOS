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
        
        //LOGIC WERE REMOVED
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
        return DataModel.shared.opportunities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = oppTableView.dequeueReusableCell(withIdentifier: "OpportunitiesReusableCell", for: indexPath) as! OpportunitiesCell
        if(!Array(DataModel.shared.opportunities)[indexPath.row].value.isScheduled!){
            cell.supplierLabel?.numberOfLines = 0
            cell.invoiceID = Array(DataModel.shared.opportunities)[indexPath.row].key
            cell.oppVIew.layer.cornerRadius = cell.oppVIew.frame.height / 9
            
            cell.supplierLabel?.text = Array(DataModel.shared.opportunities)[indexPath.row].value.debtor?.companyName
            cell.daysLabel?.text = String(Array(DataModel.shared.opportunities)[indexPath.row].value.toBeCollectedIn!)
            cell.dateLabel?.text = util.dateFormatter(Array(DataModel.shared.opportunities)[indexPath.row].value.paymentDate!)
            cell.teaLabel?.text = util.doubleFormatter(Array(DataModel.shared.opportunities)[indexPath.row].value.tea!,2)
            cell.temLabel?.text = util.doubleFormatter(Array(DataModel.shared.opportunities)[indexPath.row].value.tem!,2)
            //LOGIC WERE REMOVED
        }
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
    func didUpdateOpportunities(_ cigManager: CIGInit, _ appData: APPData) {
        util.updateFinancialValues(appData.financialBalance!)
        //LOGIC WERE REMOVED
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    @objc func refresh(_ sender: Any) {
        self.cig.getOpportunities(DataModel.shared.smartToken!, DataModel.shared.scheduledInvestmentsNum)
    }
}
