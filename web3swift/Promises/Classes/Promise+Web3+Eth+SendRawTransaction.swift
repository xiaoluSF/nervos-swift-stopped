//
//  Promise+Nervos+Eth+SendRawTransaction.swift
//  nervosswift-iOS
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension nervos.Appchain {
    func sendRawTransactionPromise(_ transaction: Data) -> Promise<TransactionSendingResult> {
        guard let deserializedTX = EthereumTransaction.fromRaw(transaction) else {
            let promise = Promise<TransactionSendingResult>.pending()
            promise.resolver.reject(NervosError.processingError("Serialized TX is invalid"))
            return promise.promise
        }
        return sendRawTransactionPromise(deserializedTX)
    }

    func sendRawTransactionPromise(_ transaction: EthereumTransaction) -> Promise<TransactionSendingResult>{
        print(transaction)
        let queue = nervos.requestDispatcher.queue
        do {
            guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {
                throw NervosError.processingError("Transaction is invalid")
            }
            let rp = nervos.dispatch(request)
            return rp.map(on: queue ) { response in
                guard let value: String = response.getValue() else {
                    if response.error != nil {
                        throw NervosError.nodeError(response.error!.message)
                    }
                    throw NervosError.nodeError("Invalid value from Ethereum node")
                }
                let result = TransactionSendingResult(transaction: transaction, hash: value)
                return result
            }
        } catch {
            let returnPromise = Promise<TransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
    func sendRawTransactionPromise(_ transaction:NervosTransaction,privateKey:String) -> Promise<NervosTransactionSendingResult> {
        let queue = nervos.requestDispatcher.queue
        do {
            guard let request = NervosTransaction.createRawTransactionRequest(transaction: transaction, privateKey: privateKey) else {
                throw NervosError.processingError("Transaction is invalid")
            }
            let rp = nervos.dispatch(request)
            return rp.map(on: queue ) { response in
                print(response.result.debugDescription)
                guard let value: [String:String] = response.getValue() else {
                    if response.error != nil {
                        throw NervosError.nodeError(response.error!.message)
                    }
                    throw NervosError.nodeError("Invalid value from Ethereum node")
                }
                let result = NervosTransactionSendingResult(transaction: transaction, hash: value["hash"]!)
                return result
            }
        } catch {
            let returnPromise = Promise<NervosTransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }

        
        
    }
    
}
