
//  Nervos+Contract.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension nervos {
    
    public func contract(_ abiString: String, at: EthereumAddress? = nil, abiVersion: Int = 2) -> nervoscontract? {
        return nervoscontract(nervos: self, abiString: abiString, at: at, options: self.options, abiVersion: abiVersion)
    }
    
    public class nervoscontract {
        var contract: ContractProtocol
        var nervos : nervos
        public var options: NervosOptions? = nil
        
        public init?(nervos nervosInstance:nervos, abiString: String, at: EthereumAddress? = nil, options: NervosOptions? = nil, abiVersion: Int = 2) {
            self.nervos = nervosInstance
            self.options = nervos.options
            switch abiVersion {
            case 1:
                print("ABIv1 bound contract is now deprecated")
                return nil
            case 2:
                guard let c = ContractV2(abiString, at: at) else {return nil}
                contract = c
            default:
                return nil
            }
            var mergedOptions = NervosOptions.merge(self.options, with: options)
            if at != nil {
                contract.address = at
                mergedOptions?.to = at
            } else if let addr = mergedOptions?.to {
                contract.address = addr
            }
            self.options = mergedOptions
        }
        
        public func deploy(bytecode: Data, parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: NervosOptions?) -> TransactionIntermediate? {
            
            let mergedOptions = NervosOptions.merge(self.options, with: options)
            guard var tx = self.contract.deploy(bytecode: bytecode, parameters: parameters, extraData: extraData, options: mergedOptions) else {return nil}
            tx.chainID = self.nervos.provider.network?.chainID
            let intermediate = TransactionIntermediate(transaction: tx, nervos: self.nervos, contract: self.contract, method: "fallback", options: mergedOptions)
            return intermediate
        }
        
        public func method(_ method:String = "fallback", parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: NervosOptions?) -> TransactionIntermediate? {
            let mergedOptions = NervosOptions.merge(self.options, with: options)
            guard var tx = self.contract.method(method, parameters: parameters, extraData: extraData, options: mergedOptions) else {return nil}
            tx.chainID = self.nervos.provider.network?.chainID
            let intermediate = TransactionIntermediate(transaction: tx, nervos: self.nervos, contract: self.contract, method: method, options: mergedOptions)
            return intermediate
        }
        
        public func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String:Any]?) {
            return self.contract.parseEvent(eventLog)
        }
        
        public func createEventParser(_ eventName:String, filter:EventFilter?) -> EventParserProtocol? {
            let parser = EventParser(nervos: self.nervos, eventName: eventName, contract: self.contract, filter: filter)
            return parser
        }
    }
}
