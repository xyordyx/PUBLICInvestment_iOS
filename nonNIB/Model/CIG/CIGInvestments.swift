//
//  CIGInvestments.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 28/12/21.
//

import Foundation
import Alamofire

protocol  CIGInvestmentsDelegate {
    func didFailWithError(error : Error)
    func didUpdateInvestments(_ cigManager: CIGInvestments,_ debtorHistory: DebtorQuery)
}

class CIGInvestments{
    
    //let currentInvestmentsUrl = "http://localhost:8080/getcurrentinvestments"
    let currentInvestmentsUrl = "https://hmnorth.uk.r.appspot.com/getcurrentinvestments"
    
    var delegate : CIGInvestmentsDelegate?
    var headers: HTTPHeaders = [
        "Authorization": "",
        "Accept": "application/json"
    ]
    
    func getCurrentInvestments(_ token: String){
        headers.update(name: "Authorization", value: token)
        AF.request(currentInvestmentsUrl, headers: headers).responseDecodable(of: DebtorQuery.self) { response in
            switch response.result{
            case .success:
                if let history = self.parseDebtorHistoryJSON(response.data!){
                    self.delegate?.didUpdateInvestments(self, history)
                }
            case .failure(let error):
                debugPrint(response)
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func parseDebtorHistoryJSON(_ finsmartData : Data) -> DebtorQuery?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(DebtorQuery.self, from: finsmartData)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
