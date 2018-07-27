//
//  Nervos+HookedWallet.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 07.01.2018.
//

import Foundation
import BigInt
import Result

extension nervos.NervosWallet {
    
    public func getAccounts() -> Result<[EthereumAddress], NervosError> {
        guard let keystoreManager = self.nervos.provider.attachedKeystoreManager else {
            return Result.failure(NervosError.walletError)
        }
        guard let ethAddresses = keystoreManager.addresses else {
            return Result.failure(NervosError.walletError)
        }
        return Result(ethAddresses)
    }
    
    public func getCoinbase() -> Result<EthereumAddress, NervosError> {
        let result = self.getAccounts()
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let addresses):
            guard addresses.count > 0 else {
                return Result.failure(NervosError.walletError)
            }
            return Result(addresses[0])
        }
    }
    
    public func signTX(transaction:inout EthereumTransaction, account: EthereumAddress, password: String = "BANKEXFOUNDATION") -> Result<Bool, NervosError> {
        do {
            guard let keystoreManager = self.nervos.provider.attachedKeystoreManager else {
                return Result.failure(NervosError.walletError)
            }
            try NervosSigner.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
            print(transaction)
            return Result(true)
        } catch {
            if error is AbstractKeystoreError {
            return Result.failure(NervosError.keystoreError(error as! AbstractKeystoreError))
            }
            return Result.failure(NervosError.generalError(error))
        }
    }
    
    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String = "BANKEXFOUNDATION") -> Result<Data, NervosError> {
        guard let data = Data.fromHex(personalMessage) else
        {
            return Result.failure(NervosError.dataError)
        }
        return self.signPersonalMessage(data, account: account, password: password)
    }
    
    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String = "BANKEXFOUNDATION") -> Result<Data, NervosError> {
        do {
            guard let keystoreManager = self.nervos.provider.attachedKeystoreManager else
            {
                return Result.failure(NervosError.walletError)
            }
            guard let data = try NervosSigner.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password) else {
                return Result.failure(NervosError.walletError)
            }
            return Result(data)
        }
        catch{
            if error is AbstractKeystoreError {
                return Result.failure(NervosError.keystoreError(error as! AbstractKeystoreError))
            }
            return Result.failure(NervosError.generalError(error))
        }
    }

}
