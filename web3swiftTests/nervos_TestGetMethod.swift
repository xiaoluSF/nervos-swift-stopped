//
//  nervos_TestGetMethod.swift
//  web3swift-iOS_Tests
//
//  Created by XiaoLu on 2018/7/18.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import XCTest
import BigInt

@testable import web3swift_iOS
class nervos_TestGetMethod: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let web3 = Web3.InfuraMainnetWeb3()
//        let peerCount = web3.eth.getPeerCount()
//        guard case .success(let currentPeerCount) = peerCount else {
//            return XCTFail()
//        }
        let blockNumber = web3.eth.getBlockNumber()
        guard case .success(let currentBlock) = blockNumber else {return XCTFail()}
        print("current block number is " + currentBlock.description)
//        print("currentPeerCount is  " + currentPeerCount.description)
        print((BigUInt(88) + currentBlock).description)
        
        let coldWalletAddress = EthereumAddress("0x6782CdeF6A4A056d412775EE6081d32B2bf90287")!

        let nt = NervosTransaction.init(to: coldWalletAddress, nonce: BigUInt(98), quota: BigUInt(200000), valid_until_block: (BigUInt(88) + currentBlock), version: BigUInt(0), data: Data.fromHex("")!, value: Data.fromHex("2")!, chain_id: BigUInt(1))
        
//        print(try! nt.signNervosTransaction(privateKey: "b5fd0cf3fc298289bad33f04b0f99eabaa12f01c1b6062347ea016315c86c974"))
        
        let result = web3.eth.sendRawTransaction(nt, privateKey: "b5fd0cf3fc298289bad33f04b0f99eabaa12f01c1b6062347ea016315c86c974")
        switch result {
        case .success(let r):
            print(r.hash)
            print(r.transaction.description)
            break
        case .failure(let error):
            print(error.localizedDescription)
            break
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
