//
//  Nervos+Methods.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public enum JSONRPCmethod: String, Encodable {
    
    case peerCount = "peerCount"
    case blockNumber = "blockNumber"
    case getNetwork = "net_version"
    case sendRawTransaction = "sendRawTransaction"
    case sendTransaction = "sendTransaction"
    case call = "call"
    case getTransactionCount = "getTransactionCount"
    case getBalance = "getBalance"
    case getCode = "getCode"
    case getStorageAt = "getStorageAt"
    case getTransaction = "getTransaction"
    case getTransactionReceipt = "getTransactionReceipt"
    case getAccounts = "accounts"
    case getBlockByHash = "getBlockByHash"
    case getBlockByNumber = "getBlockByNumber"
    case sign = "sign"
    case unlockAccount = "personal_unlockAccount"
    case getLogs = "getLogs"
    case getMetaData = "getMetaData"
    case getAbi = "getAbi"
    case getTransactionProof = "getTransactionProof"
    
    public var requiredNumOfParameters: Int {
        get {
            switch self {
            case .call:
                return 2
            case .getTransactionCount:
                return 2
            case .getBalance:
                return 2
            case .getStorageAt:
                return 2
            case .getCode:
                return 2
            case .getBlockByHash:
                return 2
            case .getBlockByNumber:
                return 2
            case .blockNumber:
                return 0
            case .getNetwork:
                return 0
            case .getAccounts:
                return 0
            default:
                return 1
            }
        }
    }
}

public struct JSONRPCRequestFabric {
    public static func prepareRequest(_ method: JSONRPCmethod, parameters: [Encodable]) -> JSONRPCrequest {
        var request = JSONRPCrequest()
        request.method = method
        let pars = JSONRPCparams(params: parameters)
        request.params = pars
        return request
    }
}
