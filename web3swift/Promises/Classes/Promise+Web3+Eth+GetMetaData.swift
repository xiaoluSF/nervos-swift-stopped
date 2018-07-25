//
//  Promise+Web3+Eth+GetMetaData.swift
//  web3swift-iOS
//
//  Created by XiaoLu on 2018/7/24.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    
    func getMetaDataPromise(_ blockNumber:BigUInt) -> Promise<MetaData>{
        return self.getMetaDataPromise(blockNumber.description)
    }
    
    func getMetaDataPromise(_ blockNumber:String) -> Promise<MetaData>{
        let request = JSONRPCRequestFabric.prepareRequest(.getMetaData, parameters: [blockNumber])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue){ response in
            guard let value: MetaData = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(response.error!.message)
                }
                throw Web3Error.nodeError("Invalid value from Nervos node")
            }
            return value
        }
    }
}
