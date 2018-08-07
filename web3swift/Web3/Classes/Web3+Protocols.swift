//
//  Nervos+Protocols.swift
//  nervosswift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result
import class PromiseKit.Promise

public protocol EventParserResultProtocol {
    var eventName: String {get}
    var decodedResult: [String:Any] {get}
    var contractAddress: EthereumAddress {get}
    var transactionReceipt: TransactionReceipt? {get}
    var eventLog: EventLog? {get}
}

public protocol EventParserProtocol {
    func parseTransaction(_ transaction: EthereumTransaction) -> Result<[EventParserResultProtocol], NervosError>
    func parseTransactionByHash(_ hash: Data) -> Result<[EventParserResultProtocol], NervosError>
    func parseBlock(_ block: Block) -> Result<[EventParserResultProtocol], NervosError>
    func parseBlockByNumber(_ blockNumber: UInt64) -> Result<[EventParserResultProtocol], NervosError>
    func parseTransactionPromise(_ transaction: EthereumTransaction) -> Promise<[EventParserResultProtocol]>
    func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResultProtocol]>
    func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResultProtocol]>
    func parseBlockPromise(_ block: Block) -> Promise<[EventParserResultProtocol]>
}

public enum Networks {
    case nervos
    case custom(networkID: BigUInt)

    var name: String {
        return ""
    }

    var chainID: BigUInt {
        switch self {
        case .nervos:
            return BigUInt(0)
        case .custom(let networkID):
            return networkID
        }
    }

    static func fromInt(_ networkID: Int) -> Networks? {
        switch networkID {
        case 0:
            return .nervos
        default:
            return .custom(networkID: BigUInt(networkID))
        }
    }
}
