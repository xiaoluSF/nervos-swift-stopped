//
//  Nervos+Instance.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

public class nervos: NervosOptionsInheritable {
    public var provider : NervosProvider
    public var options : NervosOptions = NervosOptions.defaultOptions()
    public var defaultBlock = "latest"
    public var requestDispatcher: JSONRPCrequestDispatcher
    
    public func dispatch(_ request: JSONRPCrequest) -> Promise<JSONRPCresponse> {
        return self.requestDispatcher.addToQueue(request: request)
    }

    public init(provider prov: NervosProvider, queue: OperationQueue? = nil, requestDispatcher: JSONRPCrequestDispatcher? = nil) {
        provider = prov        
        if requestDispatcher == nil {
            self.requestDispatcher = JSONRPCrequestDispatcher(provider: provider, queue: DispatchQueue.global(qos: .userInteractive), policy: .Batch(32))
        } else {
            self.requestDispatcher = requestDispatcher!
        }
    }
    
    public func addKeystoreManager(_ manager: KeystoreManager?) {
        self.provider.attachedKeystoreManager = manager
    }
    
    var ethInstance: nervos.Appchain?
    public var appchain: nervos.Appchain {
        if (self.ethInstance != nil) {
            return self.ethInstance!
        }
        self.ethInstance = nervos.Appchain(provider : self.provider, nervos: self)
        return self.ethInstance!
    }
    
    public class Appchain:NervosOptionsInheritable {
        var provider:NervosProvider
//        weak var nervos: nervos?
        var nervos: nervos
        public var options: NervosOptions {
            return self.nervos.options
        }
        public init(provider prov: NervosProvider, nervos nervosinstance: nervos) {
            provider = prov
            nervos = nervosinstance
        }
    }
    
    var personalInstance: nervos.Personal?
    public var personal: nervos.Personal {
        if (self.personalInstance != nil) {
            return self.personalInstance!
        }
        self.personalInstance = nervos.Personal(provider : self.provider, nervos: self)
        return self.personalInstance!
    }
    
    public class Personal:NervosOptionsInheritable {
        var provider:NervosProvider
        //        weak var nervos: nervos?
        var nervos: nervos
        public var options: NervosOptions {
            return self.nervos.options
        }
        public init(provider prov: NervosProvider, nervos nervosinstance: nervos) {
            provider = prov
            nervos = nervosinstance
        }
    }

    var walletInstance: nervos.NervosWallet?
    public var wallet: nervos.NervosWallet {
        if (self.walletInstance != nil) {
            return self.walletInstance!
        }
        self.walletInstance = nervos.NervosWallet(provider : self.provider, nervos: self)
        return self.walletInstance!
    }
    
    public class NervosWallet {
        var provider:NervosProvider
//        weak var nervos: nervos?
        var nervos: nervos
        public init(provider prov: NervosProvider, nervos nervosinstance: nervos) {
            provider = prov
            nervos = nervosinstance
        }
    }
    
    var browserFunctionsInstance: nervos.BrowserFunctions?
    public var browserFunctionsFunctions: nervos.BrowserFunctions {
        if (self.browserFunctionsInstance != nil) {
            return self.browserFunctionsInstance!
        }
        self.browserFunctionsInstance = nervos.BrowserFunctions(provider : self.provider, nervos: self)
        return self.browserFunctionsInstance!
    }
    
    public class BrowserFunctions:NervosOptionsInheritable {
        var provider:NervosProvider
        //        weak var nervos: nervos?
        var nervos: nervos
        public var options: NervosOptions {
            return self.nervos.options
        }
        public init(provider prov: NervosProvider, nervos nervosinstance: nervos) {
            provider = prov
            nervos = nervosinstance
        }
    }
    
}
