//
//  Promise+Nervos+Eth+Call.swift
//  nervosswift-iOS
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension nervos.Appchain {
    
    func callPromise(_ transaction: EthereumTransaction, options: NervosOptions, onBlock: String = "latest") -> Promise<Data>{
        let queue = nervos.requestDispatcher.queue
        do {
            guard let request = EthereumTransaction.createRequest(method: .call, transaction: transaction, onBlock: onBlock, options: options) else {
                throw NervosError.processingError("Transaction is invalid")
            }
            let rp = nervos.dispatch(request)
            return rp.map(on: queue ) { response in
                guard let value: Data = response.getValue() else {
                    if response.error != nil {
                        throw NervosError.nodeError(response.error!.message)
                    }
                    throw NervosError.nodeError("Invalid value from Nervos node")
                }
                return value
            }
        } catch {
            let returnPromise = Promise<Data>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
