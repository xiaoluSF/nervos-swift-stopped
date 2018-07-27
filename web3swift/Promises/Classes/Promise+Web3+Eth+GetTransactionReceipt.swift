//
//  Promise+Nervos+Eth+GetTransactionReceipt.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    public func getTransactionReceiptPromise(_ txhash: Data) -> Promise<TransactionReceipt> {
        let hashString = txhash.toHexString().addHexPrefix()
        return self.getTransactionReceiptPromise(hashString)
    }
    
    public func getTransactionReceiptPromise(_ txhash: String) -> Promise<TransactionReceipt> {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionReceipt, parameters: [txhash])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: TransactionReceipt = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Ethereum node")
            }
            return value
        }
    }
}
