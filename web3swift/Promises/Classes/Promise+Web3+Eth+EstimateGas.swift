//
//  Promise+Nervos+Eth+EstimateGas.swift
//  nervosswift-iOS
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    
//    func estimateGasPromise(_ transaction: EthereumTransaction, options: NervosOptions? = nil, onBlock: String = "latest") -> Promise<BigUInt>{
//        let queue = nervos.requestDispatcher.queue
//        do {
//            guard let request = EthereumTransaction.createRequest(method: .estimateGas, transaction: transaction, onBlock: onBlock, options: options) else {
//                throw NervosError.processingError("Transaction is invalid")
//            }
//            let rp = nervos.dispatch(request)
//            return rp.map(on: queue ) { response in
//                guard let value: BigUInt = response.getValue() else {
//                    if response.error != nil {
//                        throw NervosError.nodeError(response.error!.message)
//                    }
//                    throw NervosError.nodeError("Invalid value from Ethereum node")
//                }
//                return value
//            }
//        } catch {
//            let returnPromise = Promise<BigUInt>.pending()
//            queue.async {
//                returnPromise.resolver.reject(error)
//            }
//            return returnPromise.promise
//        }
//    }
}

