//
//  CIGScheduler.swift
//
//  Created by Martinez Giancarlo on 21/12/21.
//

import Foundation
import Alamofire

protocol CIGSchedulerDelegate{
    func didInvesmentByComplete(_ cigManager: CIGScheduler,_ data: [InvestmentJSON],_ isComplete: Bool)
    func didScheduleGotCancelled(_ cigManager: CIGScheduler,_ data: [InvestmentJSON],_ isCompleted: Bool)
    func didFailWithError(error : Error)
}

class CIGScheduler{
    
    let stopInvestmentUrl = "http://localhost:8080/stopinvestment?filter="
    let getByCompletedUrl = "http://localhost:8080/getbycompleted?filter="
    
    var delegate : CIGSchedulerDelegate?
    
    var headers: HTTPHeaders = [
        "Authorization": "",
        "Accept": "application/json"
    ]

    func getInvesmentsByCompleted(_ isCompleted: Bool){
        //headers.update(name: "firestoretoken", value: fireToken)
        AF.request(getByCompletedUrl+String(isCompleted), headers: headers).responseDecodable(of: [InvestmentJSON].self) { response in
            switch response.result{
            case .success:
                if let currentSchule = self.parseCurrentSchedule(response.data!){
                    self.delegate?.didInvesmentByComplete(self, currentSchule,isCompleted)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func cancelScheduleInvestment(_ invoiceId: String,_ isCompleted: Bool){
        //headers.update(name: "firestoretoken", value: fireToken)
        if let url = URL(string: stopInvestmentUrl+invoiceId+"&caller="+String(isCompleted)){
            //Create URL session
            let login: String = ""
            AF.request(url,
                       method: .delete,
                       parameters: login,
                       encoder: JSONParameterEncoder.default,headers: headers).responseDecodable(of: [InvestmentJSON].self) { response in
                switch response.result{
                case .success:
                    if let currentSchule = self.parseCurrentSchedule(response.data!){
                        self.delegate?.didScheduleGotCancelled(self, currentSchule,isCompleted)
                    }
                case .failure(let error):
                    self.delegate?.didFailWithError(error: error)
                }
            }
        }
    }
    
    //MARK: - PARSERS
    
    func parseCurrentSchedule(_ data : Data) -> [InvestmentJSON]?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode([InvestmentJSON].self, from: data)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
