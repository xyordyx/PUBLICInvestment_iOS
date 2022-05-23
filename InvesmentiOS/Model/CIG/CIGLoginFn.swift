//
//  CIGLoginFn.swift
//
//  Created by Martinez Giancarlo on 10/03/22.
//

import Foundation
import Alamofire

protocol  CIGLoginFnDelegate {
    func didUpdateFNToken(_ cigManager: CIGLoginFn,_ token: String,_ credential: Bool)
    func didAPPDataCreated(_ cigManager: CIGLoginFn,_ status: Bool)
    func didUserDataExists(_ cigManager: CIGLoginFn,_ status: Bool)
    func didFailWithError(error : Error)
}

class CIGLoginFn{
    var delegate : CIGLoginFnDelegate?
    let loginUrl = "https://api.platform/"
    
    let setAPPDataUrl = "http://localhost:8080/setappdata"
    let userDataUrl = "http://localhost:8080/getuserdata"
    
    
    var headers: HTTPHeaders = [
        "password": "",
        "email":"",
        "cryptpassword":"",
        "salt": "",
        "Accept": "application/json"
    ]
    
    func setAPPData(email: String, actualPassword: String){
        headers.update(name: "password", value: actualPassword)
        headers.update(name: "email", value: email)
        AF.request(setAPPDataUrl, headers: headers).responseDecodable(of: Bool.self) { response in
            switch response.result{
            case .success:
                if let opps = self.parseCreateAPPData(response.data!){
                    self.delegate?.didAPPDataCreated(self, opps)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func getFNToken(_ email: String,_ actualPassword: String,_ credential: Bool){
        if let url = URL(string: loginUrl){
            //Create URL session
            let login = LoginParameters(email: email, actualPassword: actualPassword)
            AF.request(url,
                       method: .post,
                       parameters: login,
                       encoder: JSONParameterEncoder.default).responseDecodable(of: Login.self) { response in
                switch response.result{
                case .success:
                    if let token = self.parseTokenJSON(response.data!){
                        self.delegate?.didUpdateFNToken(self, token, credential)
                    }
                case .failure(let error):
                    self.delegate?.didFailWithError(error: error)
                }
            }
        }
    }

    func getUserData(_ userEmail: String){
        headers.update(name: "userEmail", value: userEmail)
        AF.request(userDataUrl, headers: headers).responseDecodable(of: Bool.self) { response in
            switch response.result{
            case .success:
                if let opps = self.parseCreateAPPData(response.data!){
                    self.delegate?.didUserDataExists(self, opps)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }

    //MARK: - PARSE SECTION
    
    func parseTokenJSON(_ data : Data) -> String?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Login.self, from: data)
            return decodedData.accessToken
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseCreateAPPData(_ data : Data) -> Bool?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Bool.self, from: data)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
