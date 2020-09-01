//
//  BaseAPI.swift
//  Network Layer
//
//  Created by Ahmed masoud on 7/17/20.
//  Copyright © 2020 Ahmed Masoud. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class BaseAPI<T: TargetType> {
    
    func sendRequest(target: T, completion:@escaping (Result<Void, NSError>) -> Void) {
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let params = buildParams(task: target.task)
        printRequest(target: target)
        AF.request(target.baseURL + target.path, method: method, parameters: params.0, encoding: params.1, headers: headers).responseJSON { [weak self] (response) in
            guard let statusCode = response.response?.statusCode else {
                // ADD Custom Error
                completion(.failure(NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.noStatusError])))
                return
            }
            if statusCode == 200 {
                // Successful request
                completion(.success(()))
            } else {
                // ADD custom error base on status code 404 / 401 /
                if let jsonResponse = try? response.result.get(), let obj = Mapper<BaseError>().map(JSONObject: jsonResponse) {
                    completion(.failure(NSError(domain: target.baseURL, code: statusCode, userInfo: [NSLocalizedDescriptionKey: self?.parseError(errors: obj.errors ?? []) ?? ErrorMessage.genericErrorMessage])))
                    return
                }
                completion(.failure(NSError(domain: target.baseURL, code: statusCode, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.genericErrorMessage])))
            }
        }
    }
    
    func fetchData<M: Mappable>(target: T, responseClass: M.Type, completion:@escaping (Result<M?, NSError>) -> Void) {
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let params = buildParams(task: target.task)
        printRequest(target: target)
        AF.request(target.baseURL + target.path, method: method, parameters: params.0, encoding: params.1, headers: headers).responseJSON { [weak self] (response) in
            guard let statusCode = response.response?.statusCode else {
                // ADD Custom Error
                completion(.failure(NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.noStatusError])))
                return
            }
            if statusCode == 200 {
                // Successful request
                guard let jsonResponse = try? response.result.get() else {
                    // ADD Custom Error
                    completion(.failure(NSError(domain: target.baseURL, code: statusCode, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.noResponseError])))
                    return
                }
                
                guard let obj = Mapper<M>().map(JSONObject: jsonResponse) else {
                    // ADD Custom Error
                    completion(.failure(NSError(domain: target.baseURL, code: statusCode, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.decodeError])))
                    return
                }
                
                completion(.success(obj))
            } else {
                // ADD custom error base on status code 404 / 401 /
                if let jsonResponse = try? response.result.get(), let obj = Mapper<BaseError>().map(JSONObject: jsonResponse) {
                    completion(.failure(NSError(domain: target.baseURL, code: statusCode, userInfo: [NSLocalizedDescriptionKey: self?.parseError(errors: obj.errors ?? []) ?? ErrorMessage.genericErrorMessage])))
                    return
                }
                completion(.failure(NSError(domain: target.baseURL, code: statusCode, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.genericErrorMessage])))
            }
        }
    }
    
    private func parseError(errors: [String]) -> String {
        var message = ErrorMessage.genericErrorMessage
        if !errors.isEmpty {
            message = ""
            let count = errors.count
            errors.forEach({message.append(count > 1 ? "-\($0)\n" : "\($0)\n")})
            message.removeLast(1)
        }
        return message
    }
    
    
    private func buildParams(task: Task) -> ([String:Any], ParameterEncoding) {
        switch task {
        case .requestPlain:
            return ([:], URLEncoding.default)
        case .requestParameters(parameters: let parameters, encoding: let encoding):
            return (parameters, encoding)
        }
    }
    
    private func printRequest(target: T) {
        print("###")
        print("request called: \(target.baseURL)\(target.path)")
        print("http method: \(target.method)")
        if let headers = target.headers {
            print("headers: \(headers)")
        }
        print("parameters: \(target.task)")
        print("###")
    }
}

