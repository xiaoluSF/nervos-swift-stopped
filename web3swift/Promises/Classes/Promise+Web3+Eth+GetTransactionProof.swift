//
//  Promise+Web3+Eth+GetTransactionProof.swift
//  web3swift
//
//  Created by XiaoLu on 2018/7/24.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension web3.Eth {
    public func getTransactionProofPromise(transactionHash: Data) -> Promise<Data> {
        let tHash = transactionHash.toHexString().addHexPrefix()
        return self.getTransactionProofPromise(transactionHash:tHash)
    }
    
    public func getTransactionProofPromise(transactionHash: String) -> Promise<Data> {
        let tHash = transactionHash.addHexPrefix()
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionProof, parameters: [tHash])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: Data = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(response.error!.message)
                }
                throw Web3Error.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
