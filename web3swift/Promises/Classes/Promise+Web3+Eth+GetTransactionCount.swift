//
//  Promise+Nervos+Eth+GetTransactionCount.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    public func getTransactionCountPromise(address: EthereumAddress, onBlock: String = "latest") -> Promise<BigUInt> {
        let addr = address.address
        return getTransactionCountPromise(address: addr, onBlock: onBlock)
    }
    
    public func getTransactionCountPromise(address: String, onBlock: String = "latest") -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionCount, parameters: [address.lowercased(), onBlock])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Ethereum node")
            }
            return value
        }
    }
}
