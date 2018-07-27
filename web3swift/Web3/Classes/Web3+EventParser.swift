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
    public struct EventParser: EventParserProtocol {

        public var contract: ContractProtocol
        public var eventName: String
        public var filter: EventFilter?
        var nervos: nervos
        public init? (nervos nervosInstance: nervos, eventName: String, contract: ContractProtocol, filter: EventFilter? = nil) {
            guard let _ = contract.allEvents.index(of: eventName) else {return nil}
            self.eventName = eventName
            self.nervos = nervosInstance
            self.contract = contract
            self.filter = filter
        }
        
        public func parseBlockByNumber(_ blockNumber: UInt64) -> Result<[EventParserResultProtocol], NervosError> {
            do {
                let result = try self.parseBlockByNumberPromise(blockNumber).wait()
                return Result(result)
            } catch {
                if let err = error as? NervosError {
                    return Result.failure(err)
                }
                return Result.failure(NervosError.generalError(error))
            }
        }
        
        public func parseBlock(_ block: Block) -> Result<[EventParserResultProtocol], NervosError> {
            do {
                let result = try self.parseBlockPromise(block).wait()
                return Result(result)
            } catch {
                if let err = error as? NervosError {
                    return Result.failure(err)
                }
                return Result.failure(NervosError.generalError(error))
            }
        }
        
        public func parseTransactionByHash(_ hash: Data) -> Result<[EventParserResultProtocol], NervosError> {
            do {
                let result = try self.parseTransactionByHashPromise(hash).wait()
                return Result(result)
            } catch {
                if let err = error as? NervosError {
                    return Result.failure(err)
                }
                return Result.failure(NervosError.generalError(error))
            }
        }
        
        public func parseTransaction(_ transaction: EthereumTransaction) -> Result<[EventParserResultProtocol], NervosError> {
            do {
                let result = try self.parseTransactionPromise(transaction).wait()
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
//    public func parseBlockByNumber(_ blockNumber: UInt64) -> Result<[EventParserResultProtocol], NervosError> {
//        if self.filter != nil && (self.filter?.fromBlock != nil || self.filter?.toBlock != nil) {
//            return Result([EventParserResultProtocol]())
//        }
//        let response = nervos.eth.getBlockByNumber(blockNumber)
//        switch response {
//        case .success(let block):
//            return parseBlock(block)
//        case .failure(let error):
//            return Result.failure(error)
//        }
//    }
//
//    public func parseBlock(_ block: Block) -> Result<[EventParserResultProtocol], NervosError> {
//        guard let bloom = block.logsBloom else {return Result.failure(NervosError.dataError)}
//        if self.contract.address != nil {
//            let addressPresent = block.logsBloom?.test(topic: self.contract.address!.addressData)
//            if (addressPresent != true) {
//                return Result([EventParserResultProtocol]())
//            }
//        }
//        guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPrecence(eventName: self.eventName, bloom: bloom) else {return Result.failure(NervosError.dataError)}
//        if (!eventOfSuchTypeIsPresent) {
//            return Result([EventParserResultProtocol]())
//        }
//        var allResults = [EventParserResultProtocol]()
//        for transaction in block.transactions {
//            switch transaction {
//            case .null:
//                return Result.failure(NervosError.dataError)
//            case .transaction(let tx):
//                guard let hash = tx.hash else {return Result.failure(NervosError.dataError)}
//                let subresult = parseTransactionByHash(hash)
//                switch subresult {
//                case .failure(let error):
//                    return Result.failure(error)
//                case .success(let subsetOfEvents):
//                    allResults += subsetOfEvents
//                }
//            case .hash(let hash):
//                let subresult = parseTransactionByHash(hash)
//                switch subresult {
//                case .failure(let error):
//                    return Result.failure(error)
//                case .success(let subsetOfEvents):
//                    allResults += subsetOfEvents
//                }
//            }
//        }
//        return Result(allResults)
//    }
//
//    public func parseTransactionByHash(_ hash: Data) -> Result<[EventParserResultProtocol], NervosError> {
//        if self.filter != nil && (self.filter?.fromBlock != nil || self.filter?.toBlock != nil) {
//            return Result([EventParserResultProtocol]())
//        }
//        let response = nervos.eth.getTransactionReceipt(hash)
//        switch response {
//        case .failure(let error):
//            return Result.failure(error)
//        case .success(let receipt):
//            guard let results = parseReceiptForLogs(receipt: receipt, contract: self.contract, eventName: self.eventName, filter: self.filter) else {return Result.failure(NervosError.dataError)}
//            return Result(results)
//        }
//    }
//
//    public func parseTransaction(_ transaction: EthereumTransaction) -> Result<[EventParserResultProtocol], NervosError> {
//        guard let hash = transaction.hash else {return Result.failure(NervosError.dataError)}
//        return self.parseTransactionByHash(hash)
//    }
//
//}

extension nervos.nervoscontract.EventParser {
    public func parseTransactionPromise(_ transaction: EthereumTransaction) -> Promise<[EventParserResultProtocol]> {
        let queue = self.nervos.requestDispatcher.queue
        do {
            guard let hash = transaction.hash else {
                throw NervosError.processingError("Failed to get transaction hash")}
            return self.parseTransactionByHashPromise(hash)
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
    public func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResultProtocol]> {
        let queue = self.nervos.requestDispatcher.queue
        return self.nervos.appchain.getTransactionReceiptPromise(hash).map(on:queue) {receipt throws -> [EventParserResultProtocol] in
            guard let results = parseReceiptForLogs(receipt: receipt, contract: self.contract, eventName: self.eventName, filter: self.filter) else {
                    throw NervosError.processingError("Failed to parse receipt for events")
            }
            return results
        }
    }
    
    public func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResultProtocol]> {
        let queue = self.nervos.requestDispatcher.queue
        do {
            if self.filter != nil && (self.filter?.fromBlock != nil || self.filter?.toBlock != nil) {
                throw NervosError.inputError("Can not mix parsing specific block and using block range filter")
            }
//            return self.nervos.eth.getBlockByNumberPromise(blockNumber).then(on: queue) {res in
//                return self.parseBlockPromise(res)
//            }
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            return returnPromise.promise
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
    public func parseBlockPromise(_ block: Block) -> Promise<[EventParserResultProtocol]> {
        let queue = self.nervos.requestDispatcher.queue
        do {
            guard let bloom = block.logsBloom else {
                throw NervosError.processingError("Block doesn't have a bloom filter log")
            }
            if self.contract.address != nil {
                let addressPresent = block.logsBloom?.test(topic: self.contract.address!.addressData)
                if (addressPresent != true) {
                    let returnPromise = Promise<[EventParserResultProtocol]>.pending()
                    queue.async {
                        returnPromise.resolver.fulfill([EventParserResultProtocol]())
                    }
                    return returnPromise.promise
                }
            }
            guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPrecence(eventName: self.eventName, bloom: bloom) else {
                throw NervosError.processingError("Error processing bloom for events")
            }
            if (!eventOfSuchTypeIsPresent) {
                let returnPromise = Promise<[EventParserResultProtocol]>.pending()
                queue.async {
                    returnPromise.resolver.fulfill([EventParserResultProtocol]())
                }
                return returnPromise.promise
            }
            return Promise {seal in
                
                var pendingEvents : [Promise<[EventParserResultProtocol]>] = [Promise<[EventParserResultProtocol]>]()
                for transaction in block.transactions {
                    switch transaction {
                    case .null:
                        seal.reject(NervosError.processingError("No information about transactions in block"))
                        return
                    case .transaction(let tx):
                        guard let hash = tx.hash else {
                            seal.reject(NervosError.processingError("Failed to get transaction hash"))
                            return
                        }
                        let subresultPromise = self.parseTransactionByHashPromise(hash)
                        pendingEvents.append(subresultPromise)
                    case .hash(let hash):
                        let subresultPromise = self.parseTransactionByHashPromise(hash)
                        pendingEvents.append(subresultPromise)
                    }
                }
                when(resolved: pendingEvents).done(on: queue){ (results:[PromiseResult<[EventParserResultProtocol]>]) throws in
                    var allResults = [EventParserResultProtocol]()
                    for res in results {
                        guard case .fulfilled(let subresult) = res else {
                            throw NervosError.processingError("Failed to parse event for one transaction in block")
                        }
                        allResults.append(contentsOf: subresult)
                    }
                    seal.fulfill(allResults)
                }.catch(on:queue) {err in
                    seal.reject(err)
                }
            }
        } catch {
//            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
//            queue.async {
//                returnPromise.resolver.fulfill([EventParserResultProtocol]())
//            }
//            return returnPromise.promise
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
}

extension nervos.nervoscontract {
    public func getIndexedEvents(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) -> Result<[EventParserResultProtocol], NervosError> {
        do {
            let result = try self.getIndexedEventsPromise(eventName: eventName, filter: filter, joinWithReceipts: joinWithReceipts).wait()
            return Result(result)
        } catch {
            if let err = error as? NervosError {
                return Result.failure(err)
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
}

extension nervos.nervoscontract {
    public func getIndexedEventsPromise(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) -> Promise<[EventParserResultProtocol]> {
        let queue = self.nervos.requestDispatcher.queue
        do {
            guard let rawContract = self.contract as? ContractV2 else {
                throw NervosError.nodeError("ABIv1 is not supported for this method")
            }
            guard let preEncoding = encodeTopicToGetLogs(contract: rawContract, eventName: eventName, filter: filter) else {
                throw NervosError.processingError("Failed to encode topic for request")
            }
            //            var event: ABIv2.Element.Event? = nil
            if eventName != nil {
                guard let _ = rawContract.events[eventName!] else {
                    throw NervosError.processingError("No such event in a contract")
                }
                //                event = ev
            }
            let request = JSONRPCRequestFabric.prepareRequest(.getLogs, parameters: [preEncoding])
            let fetchLogsPromise = self.nervos.dispatch(request).map(on: queue) {response throws -> [EventParserResult] in
                guard let value: [EventLog] = response.getValue() else {
                    if response.error != nil {
                        throw NervosError.nodeError(response.error!.message)
                    }
                    throw NervosError.nodeError("Empty or malformed response")
                }
                let allLogs = value
                let decodedLogs = allLogs.compactMap({ (log) -> EventParserResult? in
                    let (n, d) = self.contract.parseEvent(log)
                    guard let evName = n, let evData = d else {return nil}
                    var res = EventParserResult(eventName: evName, transactionReceipt: nil, contractAddress: log.address, decodedResult: evData)
                    res.eventLog = log
                    return res
                }).filter{ (res:EventParserResult?) -> Bool in
                    if eventName != nil {
                        if res != nil && res?.eventName == eventName && res!.eventLog != nil {
                            return true
                        }
                    } else {
                        if res != nil && res!.eventLog != nil {
                            return true
                        }
                    }
                    return false
                }
                return decodedLogs
            }
            if (!joinWithReceipts) {
                return fetchLogsPromise.mapValues(on: queue) {res -> EventParserResultProtocol in
                    return res as EventParserResultProtocol
                }
            }
            return fetchLogsPromise.thenMap(on:queue) {singleEvent in
                return self.nervos.appchain.getTransactionReceiptPromise(singleEvent.eventLog!.transactionHash).map(on: queue) { receipt in
                    var joinedEvent = singleEvent
                    joinedEvent.transactionReceipt = receipt
                    return joinedEvent as EventParserResultProtocol
                }
            }
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}




