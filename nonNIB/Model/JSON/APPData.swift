//
//  APPData.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 11/03/22.
//

import Foundation

class APPData: Codable{
    var financialBalance: FinancialData?
    var opportunities: [Opportunities]?
    
    func APPData(_finanBalance: FinancialData, _opps: [Opportunities]){
        self.financialBalance = _finanBalance
        self.opportunities = _opps
    }
    
}
