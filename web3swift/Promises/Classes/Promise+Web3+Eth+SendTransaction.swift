//
//  Promise+Nervos+Eth+SendTransaction.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    
    func sendTransactionPromise(_ transaction: EthereumTransaction, options: NervosOptions, password:String = "BANKEXFOUNDATION") -> Promise<TransactionSendingResult> {
        print(transaction)
        var assembledTransaction : EthereumTransaction = transaction.mergedWithOptions(options)
        let queue = nervos.requestDispatcher.queue
        do {
            if self.nervos.provider.attachedKeystoreManager == nil {
                guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.sendTransaction, transaction: assembledTransaction, onBlock: nil, options: options) else
                {
                    throw NervosError.processingError("Failed to create a request to send transaction")
                }
                return self.nervos.dispatch(request).map(on: queue) {response in
                    guard let value: String = response.getValue() else {
                        if response.error != nil {
                            throw NervosError.nodeError(response.error!.message)
                        }
                        throw NervosError.nodeError("Invalid value from Ethereum node")
                    }
                    let result = TransactionSendingResult(transaction: assembledTransaction, hash: value)
                    return result
                }
            }
            guard let from = options.from else {
                throw NervosError.inputError("No 'from' field provided")
            }
            do {
                try NervosSigner.signTX(transaction: &assembledTransaction, keystore: self.nervos.provider.attachedKeystoreManager!, account: from, password: password)
            } catch {
                throw NervosError.inputError("Failed to locally sign a transaction")
            }
            return self.nervos.appchain.sendRawTransactionPromise(assembledTransaction)
        } catch {
            let returnPromise = Promise<TransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
        

        
    }
}
