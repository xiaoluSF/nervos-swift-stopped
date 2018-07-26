//
//  Promise+Nervos+Eth+GetCode.swift
//  nervosswift-iOS
//
//  Created by XiaoLu on 2018/7/24.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

extension nervos.Appchain {
    public func getCodePromise(address: String, onBlock: String = "latest") -> Promise<Data> {
        let request = JSONRPCRequestFabric.prepareRequest(.getCode, parameters: [address.lowercased(), onBlock])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: Data = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}

