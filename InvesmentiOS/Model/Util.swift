//
//  Util.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 16/11/21.
//

import Foundation
import UIKit

struct Util{
    func doubleFormatter(_ basedOn : Double, _ decimals : Int) -> String?{
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .down
        return formatter.string(from: NSNumber(value: basedOn)) ?? "0.00"
    }
    
    func dateFormatter(_ dateString: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from:dateString)!
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from:date)
    }
    
    func historyDateFormatter(_ dateString: String) -> String{
        var prefix = ""
        if let index = dateString.range(of: "T",options: .backwards){
            prefix = String(dateString[..<index.lowerBound])
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from:prefix)!
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from:date)
    }
    
    func setScheduled(_ scheduled: [InvestmentJSON]) -> [String: InvestmentJSON]{
        var scheduleDict = [String: InvestmentJSON]()
        if scheduleDict.isEmpty{
            for sche in scheduled{
                scheduleDict[sche.invoiceId] = sche
            }
        }
        else{
            for sche in scheduled{
                if(scheduleDict[sche.invoiceId] == nil){
                    scheduleDict[sche.invoiceId] = sche
                }
            }
        }
        return scheduleDict
    }
    
    func setInvoices(_ dataModel: DataModel,_ opps: [Opportunities]) -> [String : Opportunities]{
        //LOGIC WERE REMOVED
        return invoiceDict
    }

    func getColorRate(_ rate: String?) -> UIColor{
        if let temp = rate{
            if temp.contains("A"){
                //#colorLiteral()
                return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            }else if temp.contains("B"){
                return UIColor.systemYellow
            }
        }
        return #colorLiteral(red: 1, green: 0.2949872613, blue: 0.3388307095, alpha: 1)
    }
    
    func getStatsArray() -> [[Any]]{
        var stats = [[]]
        
        let inProgress = ["Invested in Progress",DataModel.shared.financialStats.totalPENCurrentInvested!,DataModel.shared.financialStats.totalUSDCurrentInvested!, #colorLiteral(red: 0.3173507452, green: 0.4767736197, blue: 0.8152994514, alpha: 1)] as [Any]
        let profited = ["Total Profited",DataModel.shared.financialStats.totalPENProfited!,
                        DataModel.shared.financialStats.totalUSDProfited!, #colorLiteral(red: 0, green: 0.6249273419, blue: 0.2360118032, alpha: 1)] as [Any]
        let available = ["Available to Invest",DataModel.shared.financialStats.totalPENAvailable!,
                         DataModel.shared.financialStats.totalUSDAvailable!, #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1) ] as [Any]
        let transferred = ["Total Transferred",DataModel.shared.financialStats.totalPENDeposited!,
                           DataModel.shared.financialStats.totalUSDDeposited!, #colorLiteral(red: 0.1417792141, green: 0.5480900407, blue: 0.784737587, alpha: 1) ] as [Any]
        let forecast = ["Forecast Profit",DataModel.shared.financialStats.totalPENForecast!,
                           DataModel.shared.financialStats.totalUSDForecast!, #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) ] as [Any]
        let onRisk = ["On Risk (21 Days)",DataModel.shared.financialStats.totalPENOnRisk!,
                      DataModel.shared.financialStats.totalUSDOnRisk!, #colorLiteral(red: 0.9629413486, green: 0.1961050928, blue: 0.09021706134, alpha: 1) ] as [Any]
    
        stats.append(available)
        stats.append(inProgress)
        stats.append(profited)
        stats.append(transferred)
        stats.append(forecast)
        stats.append(onRisk)
        stats.remove(at: 0)
        return stats
    }
    
    func getDelayedInvoices(_ invoices : [DebtorInvoices?]) -> [DebtorInvoices]{
        //LOGIC WERE REMOVED
        return delayedInvoices.sorted(by: { ($0.moraDays!) < ($1.moraDays!)})
    }
    
    func getRemovedInvestments(_ data: [InvestmentJSON]) -> [InvestmentJSON]{
        //LOGIC WERE REMOVED
        return currentInvoices
    }
    
    func getCloseToPayInvoices(_ invoices : [DebtorInvoices?]) -> [DebtorInvoices]{
        //LOGIC WERE REMOVED
        return closeToPay.sorted(by: { ($0.moraDays!) < ($1.moraDays!)})
    }
    
    func getDebtorInvoices(_ invoices : [DebtorInvoices?],_ value : String) -> [DebtorInvoices]{
        //LOGIC WERE REMOVED
        return query.sorted(by: { ($0.moraDays!) < ($1.moraDays!)})
    }

}

