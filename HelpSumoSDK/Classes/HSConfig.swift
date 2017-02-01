//
//  HSConfig.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 18/01/17.
//
//

import Foundation
import SystemConfiguration

public class HSConfig
{
    public static let defaults = UserDefaults.standard
    
    public init()
    {
        
    }
    
    public static func setAPIKey(apiKey: String)
    {
        self.defaults.set(apiKey, forKey: "ApiKey")
    }
    
    public static func getAPIKey()->String!
    {
        if (String(describing: self.defaults.value(forKey: "ApiKey")) == "nil")
        {
            return ""
        }
        else
        {
            return self.defaults.value(forKey: "ApiKey") as! String
        }
    }
    
    public static func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
