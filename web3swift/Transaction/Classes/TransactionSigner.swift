//
//  TransactionSigner.swift
//  nervosswift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

public enum TransactionSignerError: Error {
    case signatureError(String)
}

public struct NervosSigner {
    public static func signTX(transaction:inout EthereumTransaction, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer {Data.zero(&privateKey)}
        if (transaction.chainID != nil) {
            try EIP155Signer.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        } else {
            try FallbackSigner.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        }
    }
    public static func signIntermediate(intermediate:inout TransactionIntermediate, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws {
        var tx = intermediate.transaction
        try NervosSigner.signTX(transaction: &tx, keystore: keystore, account: account, password: password, useExtraEntropy: useExtraEntropy)
        intermediate.transaction = tx
    }
    public static func signPersonalMessage(_ personalMessage: Data, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws -> Data? {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer {Data.zero(&privateKey)}
        guard let hash = Nervos.Utils.hashPersonalMessage(personalMessage) else {return nil}
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        return compressedSignature
    }
    
    public struct EIP155Signer {
        public static func sign(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            for _ in 0..<1024 {
                let result = self.attemptSignature(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
                if (result) {
                    return
                }
            }
            throw AbstractKeystoreError.invalidAccountError
        }
        
        private static func attemptSignature(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) -> Bool {
            guard let chainID = transaction.chainID else {return false}
            guard let hash = transaction.hashForSignature(chainID: chainID) else {return false}
            let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            guard let serializedSignature = signature.serializedSignature else {return false}
            guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {
                return false
            }
            let originalPublicKey = SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.v = BigUInt(unmarshalledSignature.v) + BigUInt(35) + chainID + chainID
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            if (!(originalPublicKey!.constantTimeComparisonTo(recoveredPublicKey))) {
                return false
            }
            return true
        }
    }
    
    public struct FallbackSigner {
        public static func sign(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            for _ in 0..<1024 {
                let result = self.attemptSignature(transaction: &transaction, privateKey: privateKey)
                if (result) {
                    return
                }
            }
            throw AbstractKeystoreError.invalidAccountError
        }
        
        private static func attemptSignature(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) -> Bool {
            guard let hash = transaction.hashForSignature(chainID: nil) else {return false}
            let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            guard let serializedSignature = signature.serializedSignature else {return false}
            guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {
                return false
            }
            let originalPublicKey = SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.chainID = nil
            transaction.v = BigUInt(unmarshalledSignature.v)// + BigUInt(27)
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            if (!(originalPublicKey!.constantTimeComparisonTo(recoveredPublicKey))) {
                return false
            }
            return true
        }
    }
    
    
    public static func signNervosTransaction(transaction:inout NervosTransaction, keystore: AbstractKeystore, account: EthereumAddress, password: String) throws -> String {
        var tx = Transaction()
        tx.nonce = transaction.nonce.description
        tx.to = transaction.to.address
        tx.quota = UInt64(transaction.quota)
        tx.data = transaction.data
        tx.version = UInt32(transaction.version)
        tx.value = transaction.value
        tx.chainID = UInt32(transaction.chain_id)
        let binaryData: Data = try! tx.serializedData()
        let protobufHash = binaryData.sha3(.keccak256)
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer {Data.zero(&privateKey)}

        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: protobufHash, privateKey: privateKey, useExtraEntropy: false)
        guard let signature = compressedSignature else {
            throw TransactionError.unknownError
        }
        var unverify_tx = UnverifiedTransaction()
        unverify_tx.transaction = tx
        unverify_tx.signature = signature
        unverify_tx.crypto = .secp
        let unverfyData:Data = try! unverify_tx.serializedData()
        let signed_data = unverfyData.toHexString()
        
        return signed_data
    }
    
    
}




