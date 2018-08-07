//
//  XCTestCase+Config.swift
//  web3swift-iOS_Tests
//
//  Created by Yate Fulham on 2018/08/08.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import web3swift_iOS

extension XCTestCase {
    var defaultNervosProvider: nervos {
        return Nervos.defaultNervosProvider(host: "http://121.196.200.225:1337/")
    }
}
