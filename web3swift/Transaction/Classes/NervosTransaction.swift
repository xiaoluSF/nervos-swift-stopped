//
//  NervosTransaction.swift
//  nervosswift-iOS
//
//  Created by XiaoLu on 2018/7/18.
//  Copyright © 2018年 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public enum TransactionError:Error{
    case privateKeyIsNull
    case signatureFaild
    case unknownError
}

public struct NervosTransaction : CustomStringConvertible {
    
    public var to:EthereumAddress
    public var nonce : BigUInt
    public var quota : BigUInt = BigUInt(100000)
    public var valid_until_block : BigUInt
    public var version : BigUInt
    public var data : Data
    public var value : Data
    public var chain_id : BigUInt
    
    public init(to:EthereumAddress,nonce:BigUInt,quota:BigUInt,valid_until_block:BigUInt,version:BigUInt,data:Data,value:Data,chain_id:BigUInt){
        self.nonce = nonce
        self.to = to
        self.quota = quota
        self.valid_until_block = valid_until_block
        self.version = version
        self.data = data
        self.value = value
        self.chain_id = chain_id
    }
    
    
    public var description: String{
        get{
            var toReturn = ""
            toReturn = toReturn + "Transaction" + "\n"
            toReturn = toReturn + "nonce: " + String(self.nonce) + "\n"
            toReturn = toReturn + "to: " + String(self.to.address) + "\n"
            toReturn = toReturn + "quota: " + String(self.quota) + "\n"
            toReturn = toReturn + "valid_until_block: " + String(self.valid_until_block) + "\n"
            toReturn = toReturn + "version: " + String(self.version) + "\n"
            toReturn = toReturn + "data: " + String(self.data.toHexString()) + "\n"
            toReturn = toReturn + "value: " + String(self.value.toHexString()) + "\n"
            toReturn = toReturn + "chain_id: " + String(self.chain_id)
            return toReturn
        }
    }
    
    
    public func signNervosTransaction(privateKey:String) throws -> String{
        var tx = Transaction()
        tx.nonce = nonce.description
        tx.to = to.address
        tx.quota = UInt64(quota)
        tx.data = data
        tx.version = UInt32(version)
        tx.value = value
        tx.chainID = UInt32(chain_id)
        tx.validUntilBlock = UInt64(valid_until_block)
        let binaryData: Data = try! tx.serializedData()
        
        print(">>>>>>>>>>" + binaryData.toHexString())
        
        guard let privateKeyData = Data.fromHex(privateKey) else{
            throw TransactionError.privateKeyIsNull
        }
        let protobufHash = binaryData.sha3(.sha256)
        print("protobufHash:" + protobufHash.toHexString())
        
//        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: protobufHash, privateKey: privateKeyData, useExtraEntropy: false)
        
        guard var recoverableSignature = SECP256K1.recoverableSign(hash: protobufHash, privateKey: privateKeyData) else {
            throw TransactionError.unknownError
        }
        guard let signature = SECP256K1.serializeSignature(recoverableSignature: &recoverableSignature) else {
            throw TransactionError.unknownError
        }
        
//        guard let signature = compressedSignature else {
//            throw TransactionError.unknownError
//        }
        print("signature:++++++ " + signature.toHexString())

        var unverify_tx = UnverifiedTransaction()
        unverify_tx.transaction = tx
        unverify_tx.signature = signature
        unverify_tx.crypto = .secp
        let unverfyData:Data = try! unverify_tx.serializedData()
        var signed_data = unverfyData.toHexString()
        if !signed_data.hasPrefix("0x") {
            signed_data = "0x" + signed_data
        }
        return signed_data
    }
    
    
    
    

    
    static func createRawTransactionRequest(transaction: NervosTransaction,privateKey:String) -> JSONRPCrequest? {
        let txSignStr = try! transaction.signNervosTransaction(privateKey: privateKey)
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.sendRawTransaction
        
        let params = [txSignStr] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid {return nil}
        return request
    }
    
    
    
    
    
    
    
}
