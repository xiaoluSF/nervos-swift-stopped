//
//  Promise+Nervos+Eth+GetTransactionProof.swift
//  nervosswift
//
//  Created by XiaoLu on 2018/7/24.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension nervos.Appchain {
    public func getTransactionProofPromise(transactionHash: Data) -> Promise<Data> {
        let tHash = transactionHash.toHexString().addHexPrefix()
        return self.getTransactionProofPromise(transactionHash:tHash)
    }
    
    public func getTransactionProofPromise(transactionHash: String) -> Promise<Data> {
        let tHash = transactionHash.addHexPrefix()
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionProof, parameters: [tHash])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: Data = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
