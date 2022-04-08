//
//  StatisticsViewController.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 23/12/21.
//

import UIKit

class StatisticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CIGStatisticsDelegate{

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var spinnerVIew: UIView!
    @IBOutlet weak var statsTableView: UITableView!
    
    var stats = [[]]
    let util = Util()
    let cig = CIGStatistics()
    override func viewDidLoad() {
        super.viewDidLoad()
        statsTableView.register(UINib(nibName: "StatisticsCell", bundle: nil), forCellReuseIdentifier: "StatisticsReusableCell")
        statsTableView.dataSource = self
        statsTableView.delegate = self
        cig.delegate = self
        activityIndicator.startAnimating()
        cig.getExtraData(DataModel.shared.smartToken!)
        self.activityIndicator.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        self.view.addSubview(activityIndicator)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (stats.count <= 1){
            return 0
        }else{
            return stats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsReusableCell", for: indexPath) as! StatisticsCell
        cell.titleLabel.text = ("\(stats[indexPath.row][0])")
        cell.solesLabel.text  = "S/. "+util.doubleFormatter(stats[indexPath.row][1] as! Double,0)!
        cell.dollarLabel.text = "$ "+util.doubleFormatter(stats[indexPath.row][2] as! Double,0)!
        cell.statsView.backgroundColor = stats[indexPath.row][3] as? UIColor
        
        return cell
    }

    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateFinancialBalance(_ cigManager: CIGStatistics, _ finTran: FinancialData) {
        DataModel.shared.financialStats.totalPENForecast = finTran.solesProfitExpected
        DataModel.shared.financialStats.totalUSDForecast = finTran.dollarProfitExpected
        DataModel.shared.financialStats.totalPENOnRisk = finTran.solesOnRisk
        DataModel.shared.financialStats.totalUSDOnRisk = finTran.dollarOnRisk
        self.stats = util.getStatsArray()
        spinnerVIew.isHidden = true
        activityIndicator.stopAnimating()
        statsTableView.reloadData()
    }
}

    
