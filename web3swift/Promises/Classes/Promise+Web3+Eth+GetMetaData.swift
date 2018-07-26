//
//  Promise+Nervos+Eth+GetMetaData.swift
//  nervosswift-iOS
//
//  Created by XiaoLu on 2018/7/24.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension nervos.Appchain {
    
    func getMetaDataPromise(_ blockNumber:BigUInt) -> Promise<MetaData>{
        return self.getMetaDataPromise(blockNumber.description)
    }
    
    func getMetaDataPromise(_ blockNumber:String) -> Promise<MetaData>{
        let request = JSONRPCRequestFabric.prepareRequest(.getMetaData, parameters: [blockNumber])
        let rp = nervos.dispatch(request)
        let queue = nervos.requestDispatcher.queue
        return rp.map(on: queue){ response in
            guard let value: MetaData = response.getValue() else {
                if response.error != nil {
                    throw NervosError.nodeError(response.error!.message)
                }
                throw NervosError.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
