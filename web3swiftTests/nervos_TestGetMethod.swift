//
//  nervos_TestGetMethod.swift
//  nervosswift-iOS_Tests
//
//  Created by XiaoLu on 2018/7/18.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import XCTest
import BigInt
@testable import web3swift_iOS

class nervos_TestGetMethod: XCTestCase {
    func testExample() {
        let nervos = defaultNervosProvider
//        let peerCount = nervos.appchain.getPeerCount()
//        guard case .success(let currentPeerCount) = peerCount else {
//            return XCTFail()
//        }
        let blockNumber = nervos.appchain.getBlockNumber()
        guard case .success(let currentBlock) = blockNumber else {return XCTFail()}
//        print("current block number is " + currentBlock.description)
//        print("currentPeerCount is  " + currentPeerCount.description)
//        print((BigUInt(88) + currentBlock).description)
//
        let valueBig = Nervos.Utils.parseToBigUInt("2", units: .eth)!
        
        let coldWalletAddress = EthereumAddress("0x211C1806a6684E582fe9531803c80b5b32971461")!
        let nt = NervosTransaction.init(to: coldWalletAddress, nonce: BigUInt(233), quota: BigUInt(100000), valid_until_block: (BigUInt(88) + currentBlock), version: BigUInt(0), data: Data.fromHex("")!, value: valueBig, chain_id: BigUInt(1))

        print(try! nt.signNervosTransaction(privateKey: "b5fd0cf3fc298289bad33f04b0f99eabaa12f01c1b6062347ea016315c86c974"))

        let result = nervos.appchain.sendRawTransaction(nt, privateKey: "b5fd0cf3fc298289bad33f04b0f99eabaa12f01c1b6062347ea016315c86c974")
        switch result {
        case .success(let r):
            print(r.hash)
            print(r.transaction.description)
            break
        case .failure(let error):
            print(error.localizedDescription)
            break
        }
        
//        let receipt = nervos.eth.getTransactionReceipt("0x3fc7e352fbb16784b05a3b1f7931c8217550ce63ee30f5d1a932257e357b30db")
//        switch receipt {
//        case .success(let re):
//            print(re)
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
        
//        let nervosBlock = nervos.eth.getBlockByNumber(BigUInt(726117),fullTransactions:false)
//        switch nervosBlock {
//        case .success(let nb):
//            print(nb)
//            break
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
        
//        let mateData = nervos.eth.getMetaData(BigUInt(726117))
//        switch mateData {
//        case .success(let metaData):
//            print(metaData)
//            break
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
        
//        let transaction = nervos.eth.getTransactionDetails("0x3fc7e352fbb16784b05a3b1f7931c8217550ce63ee30f5d1a932257e357b30db")
//        switch transaction {
//        case .success(let t):
//            print(t)
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
        
        let transactionCount = nervos.appchain.getBalance(address: EthereumAddress("0x6782CdeF6A4A056d412775EE6081d32B2bf90287")!)
        switch transactionCount {
        case .success(let t):
            print(t)
        case .failure(let error):
            print(error.localizedDescription)
        }
        
//        let transactionProof = nervos.eth.getTransactionProof("0x3fc7e352fbb16784b05a3b1f7931c8217550ce63ee30f5d1a932257e357b30db")
//        switch transactionProof{
//        case .success(let r):
//            print(r.toHexString())
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
