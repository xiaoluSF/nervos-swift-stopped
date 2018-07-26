//
//  Promise+Nervos+Eth+GetPeerCount.swift
//  nervosswift-iOS
//
//  Created by XiaoLu on 2018/7/18.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    func getPeerCountPromise() -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.peerCount, parameters: [])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue){ response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
