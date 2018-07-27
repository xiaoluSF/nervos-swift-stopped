//
//  Nervos+TransactionIntermediate.swift
//  nervosswift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import enum Result.Result
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result

extension nervos.nervoscontract {

    public class TransactionIntermediate{
        public var transaction:EthereumTransaction
        public var contract: ContractProtocol
        public var method: String
        public var options: NervosOptions? = NervosOptions.defaultOptions()
        var nervos: nervos
        public init (transaction: EthereumTransaction, nervos nervosInstance: nervos, contract: ContractProtocol, method: String, options: NervosOptions?) {
            self.transaction = transaction
            self.nervos = nervosInstance
            self.contract = contract
            self.contract.options = options
            self.method = method
            self.options = NervosOptions.merge(nervos.options, with: options)
            if self.nervos.provider.network != nil {
                self.transaction.chainID = self.nervos.provider.network?.chainID
            }
        }
        
        @available(*, deprecated)
        public func setNonce(_ nonce: BigUInt) throws {
            self.transaction.nonce = nonce
            if (self.nervos.provider.network != nil) {
                self.transaction.chainID = self.nervos.provider.network?.chainID
            }
        }
        
        
        public func send(password: String = "BANKEXFOUNDATION", options: NervosOptions? = nil, onBlock: String = "pending") -> Result<TransactionSendingResult, NervosError> {
            do {
                let result = try self.sendPromise(password: password, options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? NervosError {
                    return Result.failure(err)
                }
                return Result.failure(NervosError.generalError(error))
            }
        }
        
        public func call(options: NervosOptions?, onBlock: String = "latest") -> Result<[String:Any], NervosError> {
            do {
                let result = try self.callPromise(options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? NervosError {
                    return Result.failure(err)
                }
                return Result.failure(NervosError.generalError(error))
            }
        }
        
//        public func estimateGas(options: NervosOptions?, onBlock: String = "latest") -> Result<BigUInt, NervosError> {
//            do {
//                let result = try self.estimateGasPromise(options: options, onBlock: onBlock).wait()
//                return Result(result)
//            } catch {
//                if let err = error as? NervosError {
//                    return Result.failure(err)
//                }
//                return Result.failure(NervosError.generalError(error))
//            }
//        }

        func assemble(options: NervosOptions? = nil, onBlock: String = "pending") -> Result<EthereumTransaction, NervosError> {
            do {
                let result = try self.assemblePromise(options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? NervosError {
                    return Result.failure(err)
                }
                return Result.failure(NervosError.generalError(error))
            }
        }
   
    }
}

extension nervos.nervoscontract.TransactionIntermediate {
    
    func assemblePromise(options: NervosOptions? = nil, onBlock: String = "pending") -> Promise<EthereumTransaction> {
        var assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.nervos.requestDispatcher.queue
        let returnPromise = Promise<EthereumTransaction> { seal in
            guard let mergedOptions = NervosOptions.merge(self.options, with: options) else {
                seal.reject(NervosError.inputError("Provided options are invalid"))
                return
            }
            guard let from = mergedOptions.from else {
                seal.reject(NervosError.inputError("No 'from' field provided"))
                return
            }
            var optionsForGasEstimation = NervosOptions()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let getNoncePromise : Promise<BigUInt> = self.nervos.eth.getTransactionCountPromise(address: from, onBlock: onBlock)
//            let gasEstimatePromise : Promise<BigUInt> = self.nervos.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
//            let gasPricePromise : Promise<BigUInt> = self.nervos.eth.getGasPricePromise()
            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise]
            when(resolved: getNoncePromise).map(on: queue, { (results:[PromiseResult<BigUInt>]) throws -> EthereumTransaction in
                
                promisesToFulfill.removeAll()
                guard case .fulfilled(let nonce) = results[0] else {
                    throw NervosError.processingError("Failed to fetch nonce")
                }
//                guard case .fulfilled(let gasEstimate) = results[1] else {
//                    throw NervosError.processingError("Failed to fetch gas estimate")
//                }
//                guard case .fulfilled(let gasPrice) = results[2] else {
//                    throw NervosError.processingError("Failed to fetch gas price")
//                }
//                guard let estimate = NervosOptions.smartMergeGasLimit(originalOptions: options, extraOptions: mergedOptions, gasEstimate: gasEstimate) else {
//                    throw NervosError.processingError("Failed to calculate gas estimate that satisfied options")
//                }
                assembledTransaction.nonce = nonce
//                assembledTransaction.gasLimit = estimate
//                if assembledTransaction.gasPrice == 0 {
//                    if mergedOptions.gasPrice != nil {
//                        assembledTransaction.gasPrice = mergedOptions.gasPrice!
//                    } else {
//                        assembledTransaction.gasPrice = gasPrice
//                    }
//                }
                return assembledTransaction
            }).done(on: queue) {tx in
                    seal.fulfill(tx)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    func sendPromise(password:String = "BANKEXFOUNDATION", options: NervosOptions? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult>{
        let queue = self.nervos.requestDispatcher.queue
        return self.assemblePromise(options: options, onBlock: onBlock).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            guard let mergedOptions = NervosOptions.merge(self.options, with: options) else {
                throw NervosError.inputError("Provided options are invalid")
            }
            var cleanedOptions = NervosOptions()
            cleanedOptions.from = mergedOptions.from
            cleanedOptions.to = mergedOptions.to
            return self.nervos.eth.sendTransactionPromise(transaction, options: cleanedOptions, password: password)
        }
    }
    
    func callPromise(options: NervosOptions? = nil, onBlock: String = "latest") -> Promise<[String: Any]>{
        let assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.nervos.requestDispatcher.queue
        let returnPromise = Promise<[String:Any]> { seal in
            guard let mergedOptions = NervosOptions.merge(self.options, with: options) else {
                seal.reject(NervosError.inputError("Provided options are invalid"))
                return
            }
            var optionsForCall = NervosOptions()
            optionsForCall.from = mergedOptions.from
            optionsForCall.to = mergedOptions.to
            optionsForCall.value = mergedOptions.value
            let callPromise : Promise<Data> = self.nervos.eth.callPromise(assembledTransaction, options: optionsForCall, onBlock: onBlock)
            callPromise.done(on: queue) {(data:Data) throws in
                    do {
                        if (self.method == "fallback") {
                            let resultHex = data.toHexString().addHexPrefix()
                            seal.fulfill(["result": resultHex as Any])
                            return
                        }
                        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else
                        {
                            throw NervosError.processingError("Can not decode returned parameters")
                        }
                        seal.fulfill(decodedData)
                    } catch{
                        seal.reject(error)
                    }
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
//    func estimateGasPromise(options: NervosOptions? = nil, onBlock: String = "latest") -> Promise<BigUInt>{
//        let assembledTransaction : EthereumTransaction = self.transaction
//        let queue = self.nervos.requestDispatcher.queue
//        let returnPromise = Promise<BigUInt> { seal in
//            guard let mergedOptions = NervosOptions.merge(self.options, with: options) else {
//                seal.reject(NervosError.inputError("Provided options are invalid"))
//                return
//            }
//            var optionsForGasEstimation = NervosOptions()
//            optionsForGasEstimation.from = mergedOptions.from
//            optionsForGasEstimation.to = mergedOptions.to
//            optionsForGasEstimation.value = mergedOptions.value
//            let promise = self.nervos.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
//            promise.done(on: queue) {(estimate: BigUInt) in
//                    seal.fulfill(estimate)
//                }.catch(on: queue) {err in
//                    seal.reject(err)
//            }
//        }
//        return returnPromise
//    }
}
