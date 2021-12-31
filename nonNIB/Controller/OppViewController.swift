//
//  OppViewController.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 17/11/21.
//

import UIKit

class OppViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var confirmingLabel: UILabel!
    @IBOutlet weak var confirmingView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var timeControl: UISegmentedControl!
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
        if let confirming = opportunitie?.isConfirming!{
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
        temLabel.text = util.doubleFormatter(Double((opportunitie?.tem!)!)!, 2)
        teaLabel.text = util.doubleFormatter(Double((opportunitie?.tea!)!)!, 2)
        rateLabel.text = opportunitie?.evaluation?.rating!
        amountLabel.text = util.doubleFormatter(Double((opportunitie?.advanceAmount!)!)!,2)!+" "+(opportunitie?.currency!)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func investButton(_ sender: UIButton) {
        if let amount = Double(amountTextField.text!) {
            cig.scheduleInvestment(amount, (opportunitie?.currency!)!, (opportunitie?._id)!,
                                   timeControl.selectedSegmentIndex, (opportunitie?.debtor?.companyName)!, DataModel.shared.token!)
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = detailView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            detailView.addSubview(blurEffectView)
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
    func didGotResponse(_ cigManager: CIGOpportunities, _ response: Int) {
        //Schedule successfully
        if(response == 200){
            opportunitie?.amountToInvest = Double(amountTextField.text!)!
            opportunitie?.timeToInvest = timeControl.selectedSegmentIndex
            opportunitie?.isScheduled = true
            DataModel.shared.opportunities[(opportunitie?._id)!] = opportunitie
            _ = navigationController?.popToRootViewController(animated: true)
        }
        //Investment Duplicated
        else if(response == 406){
            let alert = UIAlertController(title: "Duplicated", message: "Investment is already scheduled", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
                self.opportunitie?.isScheduled = true
                DataModel.shared.opportunities[(self.opportunitie?._id)!] = self.opportunitie
                _ = self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        //Error wrong request
        else{
            for subview in detailView.subviews {
                if subview is UIVisualEffectView {
                    subview.removeFromSuperview()
                }
            }
            let alert = UIAlertController(title: "Error", message: "Wrong request", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        let alert = UIAlertController(title: "Error", message: "Network connection refused", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
