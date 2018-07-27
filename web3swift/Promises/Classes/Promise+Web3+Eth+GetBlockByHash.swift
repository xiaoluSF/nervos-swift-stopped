//
//  Promise+Nervos+Eth+GetBlockByHash.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    public func getBlockByHashPromise(_ hash: Data, fullTransactions: Bool = false) -> Promise<NervosBlock> {
        let hashString = hash.toHexString().addHexPrefix()
        return getBlockByHashPromise(hashString, fullTransactions: fullTransactions)
    }
    
    public func getBlockByHashPromise(_ hash: String, fullTransactions: Bool = false) -> Promise<NervosBlock> {
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByHash, parameters: [hash, fullTransactions])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: NervosBlock = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
