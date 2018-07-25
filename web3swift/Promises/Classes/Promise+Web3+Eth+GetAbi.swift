//
//  Promise+Web3+Eth+GetAbi.swift
//  web3swift
//
//  Created by XiaoLu on 2018/7/24.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension web3.Eth {
    public func getAbiPromise(address: String, onBlock: String = "latest") -> Promise<Data> {
        let request = JSONRPCRequestFabric.prepareRequest(.getAbi, parameters: [address.lowercased(), onBlock])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: Data = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(response.error!.message)
                }
                throw Web3Error.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
