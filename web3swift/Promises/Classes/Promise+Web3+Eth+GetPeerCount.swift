//
//  Promise+Web3+Eth+GetPeerCount.swift
//  web3swift-iOS
//
//  Created by XiaoLu on 2018/7/18.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    func getPeerCountPromise() -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.peerCount, parameters: [])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue){ response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(response.error!.message)
                }
                throw Web3Error.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
