//
//  CIGScheduler.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 21/12/21.
//

import Foundation
import Alamofire

protocol CIGSchedulerDelegate{
    func didCurrentSchedule(_ cigManager: CIGScheduler,_ data: [InvestmentJSON])
    func didScheduleGotCancelled(_ cigManager: CIGScheduler,_ data: [InvestmentJSON],_ response: Int)
    func didFailWithError(error : Error)
}

class CIGScheduler{
    
    let currentScheduleUrl = "http://localhost:8080/currentschedule"
    let stopInvestmentUrl = "http://localhost:8080/stopinvestment?filter="
    //let currentScheduleUrl = "https://hmrestapi-333720.uk.r.appspot.com/currentschedule"
    //let stopInvestmentUrl = "https://hmrestapi-333720.uk.r.appspot.com/stopinvestment?filter="
    
    var delegate : CIGSchedulerDelegate?
    
    var headers: HTTPHeaders = [
        "Authorization": "",
        "Accept": "application/json"
    ]
    
    func getCurrentSchedule(_ token: String){
        headers.update(name: "Authorization", value: token)
        AF.request(currentScheduleUrl, headers: headers).responseDecodable(of: [InvestmentJSON].self) { response in
            switch response.result{
            case .success:
                if let currentSchule = self.parseCurrentSchedule(response.data!){
                    self.delegate?.didCurrentSchedule(self, currentSchule)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func cancelScheduleInvestment(_ invoiceId: String){
        AF.request(stopInvestmentUrl+invoiceId, headers: headers).responseDecodable(of: [InvestmentJSON].self) { response in
            switch response.result{
            case .success:
                if let currentSchule = self.parseCurrentSchedule(response.data!){
                    self.delegate?.didScheduleGotCancelled(self, currentSchule, response.response!.statusCode)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    //MARK: - PARSERS
    
    func parseCurrentSchedule(_ finsmartData : Data) -> [InvestmentJSON]?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode([InvestmentJSON].self, from: finsmartData)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
