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
        var delayedInvoices = [DebtorInvoices]()
        for inv in invoices{
            if(inv?.toBeCollectedIn == "En mora"){
                delayedInvoices.append(inv!)
            }
        }
        return delayedInvoices.sorted(by: { ($0.moraDays!) < ($1.moraDays!)})
    }
    
    func getRemovedInvestments(_ data: [InvestmentJSON]) -> [InvestmentJSON]{
        var currentInvoices = [InvestmentJSON]()
        for inv in data{
            if(inv.currentState != "Removed"){
                currentInvoices.append(inv)
            }
        }
        return currentInvoices
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
    
    func updateFinancialValues(_ APIData: FinancialData){
        DataModel.shared.financialStats.totalPENDeposited = APIData.totalPENDeposited
        DataModel.shared.financialStats.totalUSDDeposited = APIData.totalUSDDeposited
        DataModel.shared.financialStats.totalPENAvailable = APIData.totalPENAvailable
        DataModel.shared.financialStats.totalUSDAvailable = APIData.totalUSDAvailable
        DataModel.shared.financialStats.totalPENProfited = APIData.totalPENProfited
        DataModel.shared.financialStats.totalUSDProfited = APIData.totalUSDProfited
        DataModel.shared.financialStats.totalPENCurrentInvested = APIData.totalPENCurrentInvested
        DataModel.shared.financialStats.totalUSDCurrentInvested = APIData.totalUSDCurrentInvested
        DataModel.shared.financialStats.totalPENScheduled = APIData.totalPENScheduled
        DataModel.shared.financialStats.totalUSDScheduled = APIData.totalUSDScheduled
        DataModel.shared.scheduledInvestmentsNum = APIData.scheduledInvestmentsNum
    }

    func refreshBalance(_ penAvailable: UILabel, _ actualPENLabel: UILabel, _ usdAvailable: UILabel, _ actualUSDLabel: UILabel){
        if(DataModel.shared.scheduledInvestmentsNum != 0){
            if(DataModel.shared.financialStats.totalPENScheduled! > 0){
                let penRemaining = DataModel.shared.financialStats.totalPENAvailable! - DataModel.shared.financialStats.totalPENScheduled!
                penAvailable.text = "S/ "+doubleFormatter((penRemaining),0)!
                actualPENLabel.text = "Actual S/ "+doubleFormatter(DataModel.shared.financialStats.totalPENAvailable!,0)!
                actualPENLabel.isHidden = false
                penAvailable.isHidden = false
            } else{
                penAvailable.text = "S/ "+doubleFormatter(DataModel.shared.financialStats.totalPENAvailable!,0)!
                penAvailable.isHidden = false
                actualPENLabel.isHidden = true
            }
            if(DataModel.shared.financialStats.totalUSDScheduled! > 0){
                let usdReamining = DataModel.shared.financialStats.totalUSDAvailable! - DataModel.shared.financialStats.totalUSDScheduled!
                usdAvailable.text = "$ "+doubleFormatter((usdReamining),0)!
                actualUSDLabel.text = "Actual $ "+doubleFormatter(DataModel.shared.financialStats.totalUSDAvailable!,0)!
                actualUSDLabel.isHidden = false
                usdAvailable.isHidden = false
            } else{
                usdAvailable.text = "$ "+doubleFormatter(DataModel.shared.financialStats.totalUSDAvailable!,0)!
                usdAvailable.isHidden = false
                actualUSDLabel.isHidden = true
            }
        } else{
            penAvailable.text = "S/ "+doubleFormatter(DataModel.shared.financialStats.totalPENAvailable!,0)!
            usdAvailable.text = "$ "+doubleFormatter(DataModel.shared.financialStats.totalUSDAvailable!,0)!
            penAvailable.isHidden = false
            usdAvailable.isHidden = false
            actualUSDLabel.isHidden = true
            actualPENLabel.isHidden = true
        }
    }
    
    func randomString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

