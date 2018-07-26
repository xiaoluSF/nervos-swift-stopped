//
//  Nervos+Eth.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result

extension nervos.Appchain {
    
    public func sendTransaction(_ transaction: EthereumTransaction, options: NervosOptions, password:String = "BANKEXFOUNDATION") -> Result<TransactionSendingResult, NervosError> {
        do {
            let result = try self.sendTransactionPromise(transaction, options: options, password: password).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }

    func call(_ transaction: EthereumTransaction, options: NervosOptions, onBlock:String = "latest") -> Result<Data, NervosError> {
        do {
            let result = try self.callPromise(transaction, options: options, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
//    public func sendRawTransaction(_ transaction: Data) -> Result<TransactionSendingResult, NervosError> {
//        do {
//            let result = try self.sendRawTransactionPromise(transaction).wait()
//            return Result(result)
//        } catch {
//            if let err = error as? NervosError {
//                return Result.failure(err)
//            }
//            return Result.failure(NervosError.generalError(error))
//        }
//    }
    
    public func sendRawTransaction(_ transaction: EthereumTransaction) -> Result<TransactionSendingResult, NervosError> {
        do {
            let result = try self.sendRawTransactionPromise(transaction).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func sendRawTransaction(_ transaction:NervosTransaction,privateKey:String) -> Result<NervosTransactionSendingResult,NervosError>{
        do {
            let result = try self.sendRawTransactionPromise(transaction, privateKey: privateKey).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, NervosError> {
        do {
            let result = try self.getTransactionCountPromise(address: address, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getCode(address: String,onBlock: String = "latest") -> Result<Data,NervosError> {
        do {
            let result = try self.getCodePromise(address: address).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getAbi(address: String,onBlock: String = "latest") -> Result<Data,NervosError> {
        do {
            let result = try self.getAbiPromise(address: address).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getBalance(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, NervosError> {
        do {
            let result = try self.getBalancePromise(address: address, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getBlockNumber() -> Result<BigUInt, NervosError> {
        do {
            let result = try self.getBlockNumberPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getPeerCount() -> Result<BigUInt,NervosError>{
        do{
            let result = try self.getPeerCountPromise().wait()
            return Result(result)
        }catch{
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }

//    public func getGasPrice() -> Result<BigUInt, NervosError> {
//        do {
//            let result = try self.getGasPricePromise().wait()
//            return Result(result)
//        } catch {
//            if let err = error as? NervosError {
//                return Result.failure(err)
//            }
//            return Result.failure(NervosError.generalError(error))
//        }
//    }
    
    public func getTransactionDetails(_ txhash: Data) -> Result<TransactionDetails, NervosError> {
        do {
            let result = try self.getTransactionDetailsPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getTransactionDetails(_ txhash: String) -> Result<TransactionDetails, NervosError> {
        do {
            let result = try self.getTransactionDetailsPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getTransactionReceipt(_ txhash: Data) -> Result<TransactionReceipt, NervosError> {
        do {
            let result = try self.getTransactionReceiptPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getTransactionReceipt(_ txhash: String) -> Result<TransactionReceipt, NervosError> {
        do {
            let result = try self.getTransactionReceiptPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getTransactionProof(_ transactionHash:String) -> Result<Data,NervosError> {
        do {
            let result = try self.getTransactionProofPromise(transactionHash: transactionHash).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getTransactionProof(_ transactionHash:Data) -> Result<Data,NervosError> {
        do {
            let result = try self.getTransactionProofPromise(transactionHash: transactionHash).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
//    public func estimateGas(_ transaction: EthereumTransaction, options: NervosOptions?, onBlock: String = "latest") -> Result<BigUInt, NervosError> {
//        do {
//            let result = try self.estimateGasPromise(transaction, options: options, onBlock: onBlock).wait()
//            return Result(result)
//        } catch {
//            if let err = error as? NervosError {
//                return Result.failure(err)
//            }
//            return Result.failure(NervosError.generalError(error))
//        }
//    }
    
    public func getAccounts() -> Result<[EthereumAddress],NervosError> {
        do {
            let result = try self.getAccountsPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getBlockByHash(_ hash: String, fullTransactions: Bool = false) -> Result<NervosBlock,NervosError> {
        do {
            let result = try self.getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }

    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) -> Result<NervosBlock,NervosError> {
        do {
            let result = try self.getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }

    public func getBlockByNumber(_ number: UInt64, fullTransactions: Bool = false) -> Result<NervosBlock,NervosError> {
        do {
            let result = try self.getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }

    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) -> Result<NervosBlock,NervosError> {
        do {
            let result = try self.getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }

    public func getBlockByNumber(_ block:String, fullTransactions: Bool = false) -> Result<NervosBlock,NervosError> {
        do {
            let result = try self.getBlockByNumberPromise(block, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getMetaData(_ blockNumber:BigUInt) -> Result<MetaData,NervosError> {
        do {
            let result = try self.getMetaDataPromise(blockNumber).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func getMetaData(_ blockNumber:String) -> Result<MetaData,NervosError> {
        do {
            let result = try self.getMetaDataPromise(blockNumber).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func sendETH(to: EthereumAddress, amount: BigUInt, extraData: Data = Data(), options: NervosOptions? = nil) -> TransactionIntermediate? {
        let contract = self.nervos.contract(Nervos.Utils.coldWalletABI, at: to, abiVersion: 2)
        guard var mergedOptions = NervosOptions.merge(self.options, with: options) else {return nil}
        mergedOptions.value = amount
        let intermediate = contract?.method("fallback", extraData: extraData, options: mergedOptions)
        return intermediate
    }
    
    public func sendETH(to: EthereumAddress, amount: String, units: Nervos.Utils.Units = .eth, extraData: Data = Data(), options: NervosOptions? = nil) -> TransactionIntermediate? {
        guard let value = Nervos.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        return sendETH(to: to, amount: value, extraData: extraData, options: options)
    }
    
    public func sendETH(from: EthereumAddress, to: EthereumAddress, amount: String, units: Nervos.Utils.Units = .eth, extraData: Data = Data(), options: NervosOptions? = nil) -> TransactionIntermediate? {
        guard let value = Nervos.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        guard var mergedOptions = NervosOptions.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        return sendETH(to: to, amount: value, extraData: extraData, options: mergedOptions)
    }
    
    public func sendERC20tokensWithKnownDecimals(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: BigUInt, options: NervosOptions? = nil) -> TransactionIntermediate? {
        let contract = self.nervos.contract(Nervos.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        guard var mergedOptions = NervosOptions.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        guard let intermediate = contract?.method("transfer", parameters: [to, amount] as [AnyObject], options: mergedOptions) else {return nil}
        return intermediate
    }
    
    public func sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: String, options: NervosOptions? = nil) -> TransactionIntermediate? {
        let contract = self.nervos.contract(Nervos.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        guard var mergedOptions = NervosOptions.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        guard let intermediate = contract?.method("decimals", options: mergedOptions) else {return nil}
        let callResult = intermediate.call(options: mergedOptions, onBlock: "latest")
        var decimals = BigUInt(0)
        switch callResult {
        case .success(let response):
            guard let dec = response["0"], let decTyped = dec as? BigUInt else {return nil}
            decimals = decTyped
            break
        case .failure(_):
            break
        }
        let intDecimals = Int(decimals)
        guard let value = Nervos.Utils.parseToBigUInt(amount, decimals: intDecimals) else {return nil}
        return sendERC20tokensWithKnownDecimals(tokenAddress: tokenAddress, from: from, to: to, amount: value, options: options)
    }
    
}
