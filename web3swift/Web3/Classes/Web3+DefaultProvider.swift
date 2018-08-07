//
//  Nervos+DefaultProvider.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public class DefaultProvider: NervosHttpProvider {
    public init?(_ network: Networks, urlString: String, keystoreManager manager: KeystoreManager? = nil) {
        super.init(URL(string: urlString)!, network: network, keystoreManager: manager)
    }

    enum SupportedPostMethods: String {
        case ethEstimateGas = "eth_estimateGas"
        case ethSendRawTransaction = "sendRawTransaction"
    }

    enum SupportedGetMethods: String {
        case ethCall = "eth_call"
        case ethGetTransactionCount = "eth_getTransactionCount"
    }
}
