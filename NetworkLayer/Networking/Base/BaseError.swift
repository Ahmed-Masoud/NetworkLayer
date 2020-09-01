//
//  BaseError.swift
//  Network Layer
//
//  Created by Ahmed masoud on 7/17/20.
//  Copyright © 2020 Ahmed Masoud. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseError: Mappable {
    var code: Int?
    var errors: [String]?
    
    // MARK:- JSON
    required init?(map: Map) {
        self.mapping(map: map)
    }
    
    
    func mapping(map: Map) {
        code <- map["code"]
        errors <- map["errors"]
    }
}
