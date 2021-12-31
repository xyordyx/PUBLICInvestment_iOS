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
        var invoiceDict = dataModel.opportunities
        if invoiceDict.isEmpty{
            for op in opps{
                op.isScheduled = false
                op.completed = false
                invoiceDict[op._id!] = op
            }
        }
        else{
            for op in opps{
                if(invoiceDict[op._id!] == nil){
                    op.isScheduled = false
                    op.completed = false
                    invoiceDict[op._id!] = op
                }else{
                    invoiceDict[op._id!]?.availableBalanceAmount = op.availableBalanceAmount
                    invoiceDict[op._id!]?.onSale = op.onSale
                }
            }
        }
        return invoiceDict
    }
    
    func isScheduled(_ opps: [String : Opportunities], _ scheduled: [InvestmentJSON]) -> ScheduleData{
        var temp = ScheduleData()
        temp.opportunities = opps
        var amountPENInvested = 0.00
        var amountUSDInvested = 0.00
        for sche in scheduled{
            if(opps[sche.invoiceId] != nil){
                temp.opportunities[sche.invoiceId]?.isScheduled = true
                if(sche.currency == "pen"){
                    amountPENInvested = amountPENInvested + sche.amount
                }else{
                    amountUSDInvested = amountUSDInvested + sche.amount
                }
            }else{
                temp.opportunities[sche.invoiceId]?.isScheduled = false
            }
        }
        temp.amountPENScheduled = amountPENInvested
        temp.amountUSDScheduled = amountUSDInvested
        return temp
    }

    func getColorRate(_ rate: String?) -> UIColor{
        if rate!.contains("A"){
            //#colorLiteral()
            return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }else if rate!.contains("B"){
            return UIColor.systemYellow
        }else{
            return #colorLiteral(red: 1, green: 0.2949872613, blue: 0.3388307095, alpha: 1)
        }
    }
    
    func getStatsArray() -> [[Any]]{
        var stats = [[]]
        
        let inProgress = ["Invested in Progress",DataModel.shared.financialStats.totalPENInProgress!,DataModel.shared.financialStats.totalUSDInProgress!, #colorLiteral(red: 0.3173507452, green: 0.4767736197, blue: 0.8152994514, alpha: 1)] as [Any]
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
        var delayedInvoices = [DebtorInvoices]()
        for inv in invoices{
            if(inv?.toBeCollectedIn == "En mora"){
                delayedInvoices.append(inv!)
            }
        }
        return delayedInvoices.sorted(by: { ($0.moraDays!) < ($1.moraDays!)})
    }
    
    func getCloseToPayInvoices(_ invoices : [DebtorInvoices?]) -> [DebtorInvoices]{
        var closeToPay = [DebtorInvoices]()
        for inv in invoices{
            if(inv?.toBeCollectedIn != "En mora"){
                closeToPay.append(inv!)
            }
        }
        return closeToPay.sorted(by: { ($0.moraDays!) < ($1.moraDays!)})
    }
    
    func getDebtorInvoices(_ invoices : [DebtorInvoices?],_ value : String) -> [DebtorInvoices]{
        var query = [DebtorInvoices]()
        for inv in invoices{
            let isRUC = inv?.debtor?.companyRuc
            let containsName = inv?.debtor?.companyName
            if(isRUC == value){
                query.append(inv!)
            }
            else if(containsName?.range(of: value,options: String.CompareOptions.caseInsensitive) != nil){
                query.append(inv!)
            }
        }
        return query.sorted(by: { ($0.moraDays!) < ($1.moraDays!)})
    }

}

