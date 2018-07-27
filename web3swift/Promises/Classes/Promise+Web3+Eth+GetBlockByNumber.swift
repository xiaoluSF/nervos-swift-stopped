//
//  Promise+Nervos+Eth+GetBlockByNumber.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    public func getBlockByNumberPromise(_ number: UInt64, fullTransactions: Bool = false) -> Promise<NervosBlock> {
        let block = String(number, radix: 16).addHexPrefix()
        return getBlockByNumberPromise(block, fullTransactions: fullTransactions)
    }
    
    public func getBlockByNumberPromise(_ number: BigUInt, fullTransactions: Bool = false) -> Promise<NervosBlock> {
        let block = String(number, radix: 16).addHexPrefix()
        return getBlockByNumberPromise(block, fullTransactions: fullTransactions)
    }
    
    public func getBlockByNumberPromise(_ number: String, fullTransactions: Bool = false) -> Promise<NervosBlock> {
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByNumber, parameters: [number, fullTransactions])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: NervosBlock = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Ethereum node")
            }
            return value
        }
    }
}
