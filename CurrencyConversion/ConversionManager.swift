//
//  ConversionManager.swift
//  CurrencyConversion
//
//  Created by andrew lattis on 3/2/17.
//  Copyright © 2017 andrew lattis. All rights reserved.
//

import UIKit

class ConversionManager: NSObject {
    //for this simple use case there is no persistant storage, so it made sense to make this a singleton that keeps the currency conversion rates in memory
    static let shared = ConversionManager()
        
    internal var updateDate:String = ""
    internal var baseRate:String = ""
    internal var rates = Dictionary<String, Float>()
    let session = URLSession(configuration: URLSessionConfiguration.default) //for a single json request alamo fire seems like overkill, but normally i'd use it
    
    
    internal func refreshRates(handler:((Bool)->Void)?=nil) {
        self.updateRates(handler: handler)
    }
    
    
    private func updateRates(handler:((Bool)->Void)?=nil) {
        guard let url = URL(string: "https://api.fixer.io/latest?base=USD") else {
            handler?(false)
            return
        }
        
        let task = self.session.dataTask(with: url) {data, response, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if error != nil {
                handler?(false)
            } else if let response = response as? HTTPURLResponse {
                if response.statusCode == 200, let data = data {
                    let parseSuccess = self.parseRateJson(jsonData: data)
                    handler?(parseSuccess)
                } else {
                    handler?(false)
                }
            }
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        task.resume()
    }
    
    
    internal func parseRateJson(jsonData:Data)->Bool {
        var ratesJson:Dictionary<String,Any>
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: UInt(0))) as? Dictionary<String, Any> else { return false }
            ratesJson = json
        } catch { return false }
        
        
        guard let base = ratesJson["base"] as? String, let updated = ratesJson["date"] as? String, var rates = ratesJson["rates"] as? Dictionary<String, Float> else { return false }
        self.baseRate = base
        self.updateDate = updated
        
        if rates.count > 0 {
            rates[self.baseRate] = 1.0
        }
        self.rates = rates

        return true
    }
    
    
    internal func convert (amount:Float, from:String, to:String) -> Float {
        var finalAmount:Float = 0.0
        
        if from != self.baseRate {
            guard let baseConversation = self.rates[from] else { return -1.0 }
            finalAmount = amount * baseConversation
        } else {
            finalAmount = amount
        }
        
        if to != self.baseRate {
            guard let baseConversation = self.rates[to] else { return -1.0 }
            finalAmount = finalAmount * baseConversation
        }
        
        return finalAmount
    }
}
