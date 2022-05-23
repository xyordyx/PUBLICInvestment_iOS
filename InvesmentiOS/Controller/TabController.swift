//
//  TabController.swift
//
//  Created by Martinez Giancarlo on 3/12/21.
//

import UIKit

class TabController: UITabBarController {

    var data = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

}
