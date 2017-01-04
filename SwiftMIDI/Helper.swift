//
//  Helper.swift
//  SwiftMIDI
//
//  Created by Jacob Rhoda on 1/1/17.
//  Copyright © 2017 Jadar. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    private static var _onceTracker: [String] = []
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     Borrowed from our friends at SO: http://stackoverflow.com/a/38311178/943029
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        
        defer {
            objc_sync_exit(self)
        }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
