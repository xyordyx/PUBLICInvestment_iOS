//
//  LoginController.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 9/03/22.
//

import UIKit

class LoginController: UIViewController, CIGLoginFnDelegate {
    var cig = CIGLoginFn()
    let defaults = UserDefaults.standard
    
    var dataDict:[String : String] = [:]
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var email: UITextField!
    let util = Util()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cig.delegate = self
        view.backgroundColor = .systemGray6
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        activityIndicator.startAnimating()
        password.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
        loginButton.isUserInteractionEnabled = false
        loginButton.alpha = 0.2
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if let dataPList = defaults.dictionary(forKey: "userData") as? [String : String]{
            cig.getUserData(dataPList["userEmail"]!)
        }else{
            activityIndicator.stopAnimating()
            password.isUserInteractionEnabled = true
            email.isUserInteractionEnabled = true
            email.backgroundColor = .white
            password.backgroundColor = .white
            loginButton.isUserInteractionEnabled = true
            loginButton.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    @IBAction func logginButton(_ sender: UIButton) {
        activityIndicator.startAnimating()
        password.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
        email.backgroundColor = .systemGray4
        password.backgroundColor = .systemGray4
        loginButton.isUserInteractionEnabled = false
        loginButton.alpha = 0.2
        cig.getFNToken(email.text!, password.text!, false)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func didUpdateFNToken(_ cigManager: CIGLoginFn, _ finsmartToken: String,_ credential: Bool) {
        DataModel.shared.smartToken = finsmartToken
        if(!credential){
            let saltPass = util.randomString(32)
            dataDict = ["userEmail": email.text!, "password": password.text!, "credentials": "true",
                        "salt": saltPass]
            defaults.set(dataDict, forKey: "userData")
            cig.setAPPData(email: email.text!, actualPassword: password.text!, cryptpassword: saltPass)
        }else{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
    }
    
    func didUserDataExists(_ cigManager: CIGLoginFn, _ status: Bool) {
        if(status){
            if let dataPList = defaults.dictionary(forKey: "userData") as? [String : String]{
                cig.getFNToken(dataPList["userEmail"]!,dataPList["password"]!,
                               (dataPList["credentials"]!.elementsEqual("true")) ? true : false)
            }
        }else{
            defaults.removeObject(forKey: "userData")
            activityIndicator.stopAnimating()
            password.isUserInteractionEnabled = true
            email.isUserInteractionEnabled = true
            email.backgroundColor = .white
            password.backgroundColor = .white
            loginButton.isUserInteractionEnabled = true
            loginButton.alpha = 1
        }
    }
    
    func didFailWithError(error: Error) {
        //Empty base when fails
        defaults.removeObject(forKey: "userData")
        activityIndicator.stopAnimating()
        password.isUserInteractionEnabled = true
        email.isUserInteractionEnabled = true
        email.backgroundColor = .white
        password.backgroundColor = .white
        loginButton.isUserInteractionEnabled = true
        loginButton.alpha = 1
        let alert = UIAlertController(title: "Error", message: "Invalid Credentials", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didAPPDataCreated(_ cigManager: CIGLoginFn, _ status: Bool) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToHome", sender: self)
        }
    }
    
}
