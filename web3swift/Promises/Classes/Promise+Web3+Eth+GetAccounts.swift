//
//  Promise+Nervos+Eth+GetAccounts.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    public func getAccountsPromise() -> Promise<[EthereumAddress]> {
        let queue = nervos.requestDispatcher.queue
        if (self.nervos.provider.attachedKeystoreManager != nil) {
            let promise = Promise<[EthereumAddress]>.pending()
            queue.async {
                let result = self.nervos.wallet.getAccounts()
                switch result {
                case .success(let allAccounts):
                    promise.resolver.fulfill(allAccounts)
                case .failure(let error):
                    promise.resolver.reject(error)
                }
            }
            return promise.promise
        }
        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let rp = nervos.dispatch(request)
        return rp.map(on: queue ) { response in
            guard let value: [EthereumAddress] = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Ethereum node")
            }
            return value
        }
    }
}
