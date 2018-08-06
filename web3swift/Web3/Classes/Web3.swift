//
//  Nervos.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 11.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

public enum NervosError: Error {
    case transactionSerializationError
    case connectionError
    case dataError
    case walletError
    case inputError(String)
    case nodeError(String)
    case processingError(String)
    case keystoreError(AbstractKeystoreError)
    case generalError(Error)
    case unknownError
}

public struct Nervos {
    public static func new(_ providerURL: URL) -> nervos? {
        guard let provider = NervosHttpProvider(providerURL) else { return nil }
        return nervos(provider: provider)
    }

    public static func defaultNervosProvider(host: String) -> nervos {
        let infura = DefaultProvider(.nervos, urlString: host)!
        return nervos(provider: infura)
    }
}

struct ResultUnwrapper {
    static func getResponse(_ response: [String: Any]?) -> Result<Any, NervosError> {
        guard response != nil, let res = response else {
            return Result.failure(NervosError.connectionError)
        }
        if let error = res["error"] {
            if let errString = error as? String {
                return Result.failure(NervosError.nodeError(errString))
            } else if let errDict = error as? [String: Any] {
                if errDict["message"] != nil, let descr = errDict["message"]! as? String {
                    return Result.failure(NervosError.nodeError(descr))
                }
            }
            return Result.failure(NervosError.unknownError)
        }
        guard let result = res["result"] else {
            return Result.failure(NervosError.dataError)
        }
        return Result(result)
    }
}
