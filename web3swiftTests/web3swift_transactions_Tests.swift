//
//  nervosswiftTransactionsTests.swift
//  nervosswift-iOS_Tests
//
//  Created by Георгий Фесенко on 02/07/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import Result
import secp256k1_ios

@testable import web3swift_iOS

class nervosswift_transactions_Tests: XCTestCase {
    
    func testTransaction() {
        do {
            var transaction = EthereumTransaction(nonce: BigUInt(9),
                                                  gasPrice: BigUInt(20000000000),
                                                  gasLimit: BigUInt(21000),
                                                  to: EthereumAddress("0x3535353535353535353535353535353535353535")!,
                                                  value: BigUInt("1000000000000000000")!,
                                                  data: Data(),
                                                  v: BigUInt(0),
                                                  r: BigUInt(0),
                                                  s: BigUInt(0))
            let privateKeyData = Data.fromHex("0x4646464646464646464646464646464646464646464646464646464646464646")!
            let publicKey = Nervos.Utils.privateToPublic(privateKeyData, compressed: false)
            let sender = Nervos.Utils.publicToAddress(publicKey!)
            transaction.chainID = BigUInt(1)
            print(transaction)
            let hash = transaction.hashForSignature(chainID: BigUInt(1))
            let expectedHash = "0xdaf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53".stripHexPrefix()
            XCTAssert(hash!.toHexString() == expectedHash, "Transaction signature failed")
            try NervosSigner.EIP155Signer.sign(transaction: &transaction, privateKey: privateKeyData, useExtraEntropy: false)
            print(transaction)
            XCTAssert(transaction.v == UInt8(37), "Transaction signature failed")
            XCTAssert(sender == transaction.sender)
        }
        catch {
            print(error)
            XCTFail()
        }
    }
    
    func testEthSendExample() {
        let nervos = Nervos.defaultNervosProvider(host: "http://121.196.200.225:1337/")
        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        nervos.addKeystoreManager(keystoreManager)
        let contract = nervos.contract(Nervos.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        var options = NervosOptions.defaultOptions()
        options.value = Nervos.Utils.parseToBigUInt("1.0", units: .eth)
        options.from = keystoreManager.addresses?.first
        let intermediate = contract?.method("fallback", options: options)
        guard let result = intermediate?.send(password: "") else {return XCTFail()}
        switch result {
        case .success(_):
            return XCTFail()
        case .failure(let error):
            print(error)
            guard case .nodeError(let descr) = error else {return XCTFail()}
            guard descr == "insufficient funds for gas * price + value" else {return XCTFail()}
        }
    }
    
    func testTransactionReceipt() {
        let nervos = Nervos.defaultNervosProvider(host: "http://121.196.200.225:1337/")
        let result = nervos.appchain.getTransactionReceipt("0x83b2433606779fd756417a863f26707cf6d7b2b55f5d744a39ecddb8ca01056e")
        switch result {
        case .failure(let error):
            print(error)
            XCTFail()
        case .success(let response):
            print(response)
            XCTAssert(response.status == .ok)
        }
    }
    
    func testTransactionDetails() {

    }
    
    
    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
    }
    
//    func testSendETH() {
//        guard let keystoreData = getKeystoreData() else {return}
//        guard let keystoreV3 = EthereumKeystoreV3.init(keystoreData) else {return XCTFail()}
//        let nervosRinkeby = Nervos.defaultNervosProvider(host: "http://121.196.200.225:1337/")
//        let keystoreManager = KeystoreManager.init([keystoreV3])
//        nervosRinkeby.addKeystoreManager(keystoreManager)
//        guard case .success(let gasPriceRinkeby) = nervosRinkeby.eth.getGasPrice() else {return}
//        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        guard let intermediate = nervosRinkeby.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
//        var options = NervosOptions.defaultOptions()
//        options.from = keystoreV3.addresses?.first
//        options.gasPrice = gasPriceRinkeby
//        let result = intermediate.send(password: "BANKEXFOUNDATION", options: options)
//        switch result {
//        case .success(let res):
//            print(res)
//        case .failure(let error):
//            print(error)
//            XCTFail()
//        }
//    }
    
    func testTokenBalanceTransferOnMainNet() {
        // BKX TOKEN
        let nervos = Nervos.defaultNervosProvider(host: "http://121.196.200.225:1337/")
        let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!
        var options = NervosOptions()
        options.from = coldWalletAddress
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        nervos.addKeystoreManager(keystoreManager)
        let contract = nervos.contract(Nervos.Utils.erc20ABI, at: contractAddress, abiVersion: 2)!
        let bkxBalanceSend = contract.method("transfer", parameters: [coldWalletAddress, BigUInt(1)] as [AnyObject], options: options)!.call(options: nil)
        switch bkxBalanceSend {
        case .success(let result):
            print(result)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
//    func testTokenBalanceTransferOnMainNetUsingConvenience() {
//        // BKX TOKEN
//        let nervos = Nervos.InfuraMainnetNervos()
//        let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        nervos.addKeystoreManager(keystoreManager)
//        let intermediate = nervos.eth.sendERC20tokensWithNaturalUnits(tokenAddress:contractAddress, from: coldWalletAddress, to: coldWalletAddress, amount: "1.0")
//        let gasEstimate = intermediate!.estimateGas(options: nil)
//        switch gasEstimate {
//        case .success(let result):
//            print(result)
//        case .failure(let error):
//            print(error)
//            XCTFail()
//        }
//        var options = NervosOptions();
//        options.gasLimit = gasEstimate.value!
//        let bkxBalanceSend = intermediate!.call(options: options)
//        switch bkxBalanceSend {
//        case .success(let result):
//            print(result)
//        case .failure(let error):
//            print(error)
//            XCTFail()
//        }
//    }
}
