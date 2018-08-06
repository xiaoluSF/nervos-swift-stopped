//
//  Nervos+Provider.swift
//  nervosswift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

public protocol NervosProvider {
    func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse>
    func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch>
    var network: Networks? { get set }
    var attachedKeystoreManager: KeystoreManager? { get set }
    var url: URL { get }
    var session: URLSession { get }
}

public class NervosHttpProvider: NervosProvider {
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager?
    public var session: URLSession = { () -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()

    public init?(_ httpProviderURL: URL, network net: Networks? = nil, keystoreManager manager: KeystoreManager? = nil) {
        do {
            guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else { return nil }
            url = httpProviderURL
            if net == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.getNetwork, parameters: [])
                let queue = DispatchQueue.global(qos: .userInteractive)
                let response = try NervosHttpProvider.post(request, providerURL: httpProviderURL, queue: queue, session: session).wait()
                if response.error != nil {
                    if response.message != nil {
                        print(response.message!)
                    }
                    return nil
                }
                guard let result: String = response.getValue(), let intNetworkNumber = Int(result) else { return nil }
                network = Networks.fromInt(intNetworkNumber)
                if network == nil { return nil }
            } else {
                network = net
            }
        } catch {
            return nil
        }
        attachedKeystoreManager = manager
    }
}
