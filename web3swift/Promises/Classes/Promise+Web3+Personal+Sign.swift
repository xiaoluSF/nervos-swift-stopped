//
//  Promise+Nervos+Personal+Sign.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Personal {
    
    func signPersonalMessagePromise(message: Data, from: EthereumAddress, password:String = "BANKEXFOUNDATION") -> Promise<Data> {
        let queue = nervos.requestDispatcher.queue
        do {
            if self.nervos.provider.attachedKeystoreManager == nil {
                let hexData = message.toHexString().addHexPrefix()
                let request = JSONRPCRequestFabric.prepareRequest(.sign, parameters: [from.address.lowercased(), hexData])
                return self.nervos.dispatch(request).map(on: queue) {response in
                    guard let value: Data = response.getValue() else {
                        if response.error != nil {
                            throw NervosError.nodeError(response.error!.message)
                        }
                        throw NervosError.nodeError("Invalid value from Ethereum node")
                    }
                    return value
                }
            }
            guard let signature = try NervosSigner.signPersonalMessage(message, keystore: self.nervos.provider.attachedKeystoreManager!, account: from, password: password) else { throw NervosError.inputError("Failed to locally sign a message") }
            let returnPromise = Promise<Data>.pending()
            queue.async {
                returnPromise.resolver.fulfill(signature)
            }
            return returnPromise.promise
        } catch {
            let returnPromise = Promise<Data>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
