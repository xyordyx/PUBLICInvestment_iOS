//
//  OppViewController.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 17/11/21.
//

import UIKit

class OppViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var investButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var actualPENLabel: UILabel!
    @IBOutlet weak var actualUSDLabel: UILabel!
    @IBOutlet weak var confirmingLabel: UILabel!
    @IBOutlet weak var confirmingView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var temLabel: UILabel!
    @IBOutlet weak var teaLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var usdAvailable: UILabel!
    @IBOutlet weak var penAvailable: UILabel!
    @IBOutlet weak var supplierLabel: UILabel!
    
    var cig = CIGOpportunities()
    var opportunitie: Opportunities?
    let defaults = UserDefaults.standard
    
    var penAvailableAmount = 0.00
    var usdAvailableAmount = 0.00
    
    let util = Util()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        amountTextField.delegate = self
        supplierLabel.numberOfLines = 0
        detailView.layer.cornerRadius = detailView.frame.height / 13
        rateView.layer.cornerRadius = rateView.frame.height / 4
        confirmingView.layer.cornerRadius =  confirmingView.frame.height / 4
        rateView.backgroundColor = util.getColorRate(opportunitie?.evaluation?.rating!)
        if let confirming = opportunitie?.isConfirming{
            if(confirming){
                confirmingView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                confirmingLabel?.text = "C"
            }
            else{
                confirmingLabel?.text = "F"
            }
        }
        usdAvailable.text = "$ "+util.doubleFormatter(usdAvailableAmount,0)!
        penAvailable.text = "S/. "+util.doubleFormatter(penAvailableAmount,0)!
        
        supplierLabel.text = opportunitie?.debtor?.companyName
        if let days = opportunitie?.toBeCollectedIn{
            daysLabel.text = String(days)
        }
        dateLabel.text = util.dateFormatter((opportunitie?.paymentDate!)!)
        temLabel.text = util.doubleFormatter((opportunitie?.tem!)!, 2)
        teaLabel.text = util.doubleFormatter((opportunitie?.tea!)!, 2)
        rateLabel.text = opportunitie?.evaluation?.rating!
        amountLabel.text = util.doubleFormatter((opportunitie?.advanceAmount!)!,2)!+" "+(opportunitie?.currency!)!
        actualPENLabel.isHidden = true
        actualUSDLabel.isHidden = true
        self.util.refreshBalance(penAvailable,actualPENLabel,usdAvailable, actualUSDLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func investButton(_ sender: UIButton) {
        if let amount = Double(amountTextField.text!) {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            amountTextField.isUserInteractionEnabled = false
            amountTextField.backgroundColor = .systemGray4
            investButton.isUserInteractionEnabled = false
            investButton.alpha = 0.2
            if let dataPList = defaults.dictionary(forKey: "userData") as? [String : String]{
                cig.createInvestment(amount,DataModel.shared.smartToken!,dataPList["userEmail"]!, opportunitie!)
            }
        }
    }
    
    //MARK: -  TabkeView Delegate Methods
    @IBAction func historyButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goToHistory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HistoryViewController
        destinationVC.opportunitie = self.opportunitie
    }
}

extension OppViewController: CIGOppDelegate{
    func didGotResponse(_ cigManager: CIGOpportunities, _ response: Bool) {
        //Schedule successfully
        if(response){
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            _ = navigationController?.popToRootViewController(animated: true)
        }
        //Investment Duplicated or Error
        else if(!response){
            let alert = UIAlertController(title: "Error", message: "Investment is already scheduled or there was an error", preferredStyle: UIAlertController.Style.alert)
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
                _ = self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        let alert = UIAlertController(title: "Error", message: "Network connection refused", preferredStyle: UIAlertController.Style.alert)
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
