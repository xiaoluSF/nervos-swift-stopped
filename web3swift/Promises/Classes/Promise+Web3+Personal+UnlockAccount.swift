//
//  Promise+Nervos+Personal+UnlockAccount.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Personal {
    func unlockAccountPromise(account: EthereumAddress, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Promise<Bool> {
        let addr = account.address
        return unlockAccountPromise(account: addr, password: password, seconds: seconds)
    }
    
    
    func unlockAccountPromise(account: String, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Promise<Bool> {
        let queue = nervos.requestDispatcher.queue
        do {
            if self.nervos.provider.attachedKeystoreManager == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: [account.lowercased(), password, seconds])
                return self.nervos.dispatch(request).map(on: queue) {response in
                    guard let value: Bool = response.getValue() else {
                        if response.error != nil {
                            throw NervosError.nodeError(response.error!.message)
                        }
                        throw NervosError.nodeError("Invalid value from Ethereum node")
                    }
                    return value
                }
            }
            throw NervosError.inputError("Can not unlock a local keystore")
        } catch {
            let returnPromise = Promise<Bool>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
