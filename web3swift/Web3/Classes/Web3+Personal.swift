//
//  Nervos+Personal.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 14.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result

extension nervos.Personal {
    

    
    public func signPersonalMessage(message: Data, from: EthereumAddress, password:String = "BANKEXFOUNDATION") -> Result<Data, NervosError> {
        do {
            let result = try self.signPersonalMessagePromise(message: message, from: from, password: password).wait()
            return Result(result)
        } catch {
            return Result.failure(error as! NervosError)
        }
    }
    
    public func unlockAccount(account: EthereumAddress, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Result<Bool, NervosError> {
        do {
            let result = try self.unlockAccountPromise(account: account).wait()
            return Result(result)
        } catch {
            return Result.failure(error as! NervosError)
        }
    }
    
    public func ecrecover(personalMessage: Data, signature: Data) -> Result<EthereumAddress, NervosError> {
        guard let recovered = Nervos.Utils.personalECRecover(personalMessage, signature: signature) else {
            return Result.failure(NervosError.dataError)
        }
        return Result(recovered)
    }
    
    public func ecrecover(hash: Data, signature: Data) -> Result<EthereumAddress, NervosError> {
        guard let recovered = Nervos.Utils.hashECRecover(hash: hash, signature: signature) else {
            return Result.failure(NervosError.dataError)
        }
        return Result(recovered)
    }
}
