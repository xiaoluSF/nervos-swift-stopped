//
//  DataConversion.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 16.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

extension nervos.Appchain {
    public func getBalancePromise(address: EthereumAddress, onBlock: String = "latest") -> Promise<BigUInt> {
        let addr = address.address
        return getBalancePromise(address: addr, onBlock: onBlock)
    }
    public func getBalancePromise(address: String, onBlock: String = "latest") -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.getBalance, parameters: [address.lowercased(), onBlock])
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
