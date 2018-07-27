 //
//  Nervos+Structures.swift
//
//  Created by Alexander Vlasov on 26.12.2017.
//

import Foundation
import BigInt

fileprivate func decodeHexToData<T>(_ container:  KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key, allowOptional:Bool = false) throws -> Data? {
    if (allowOptional) {
        let string = try? container.decode(String.self, forKey: key)
        if string != nil {
            guard let data = Data.fromHex(string!) else {throw NervosError.dataError}
            return data
        }
        return nil
    } else {
        let string = try container.decode(String.self, forKey: key)
        guard let data = Data.fromHex(string) else {throw NervosError.dataError}
        return data
    }
}

fileprivate func decodeHexToBigUInt<T>(_ container:  KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key, allowOptional:Bool = false) throws -> BigUInt? {
    if (allowOptional) {
        let string = try? container.decode(String.self, forKey: key)
        if string != nil {
            guard let number = BigUInt(string!.stripHexPrefix(), radix: 16) else {throw NervosError.dataError}
            return number
        }
        return nil
    } else {
        let string = try container.decode(String.self, forKey: key)
        guard let number = BigUInt(string.stripHexPrefix(), radix: 16) else {throw NervosError.dataError}
        return number
    }
}

fileprivate func decodeIntToBigUInt<T>(_ container:  KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key, allowOptional:Bool = false) throws -> BigUInt? {
    if (allowOptional) {
        let string = try? container.decode(String.self, forKey: key)
        if string != nil {
            guard let number = BigUInt(string!.stripHexPrefix(), radix: 16) else {throw NervosError.dataError}
            return number
        }
        return nil
    } else {
        let int = try container.decode(Int.self, forKey: key)
//        guard let number = BigUInt(int) else {throw NervosError.dataError}
        return BigUInt(int)
    }
}

extension NervosOptions:Decodable {
    enum CodingKeys: String, CodingKey
    {
        case from
        case to
        case gasPrice
        case gas
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let gasLimit = try decodeHexToBigUInt(container, key: .gas)
        self.gasLimit = gasLimit
        
        let gasPrice = try decodeHexToBigUInt(container, key: .gasPrice)
        self.gasPrice = gasPrice
        
        let toString = try container.decode(String.self, forKey: .to)
        var to: EthereumAddress?
        if toString == "0x" || toString == "0x0" {
            to = EthereumAddress.contractDeploymentAddress()
        } else {
            guard let ethAddr = EthereumAddress(toString) else {throw NervosError.dataError}
            to = ethAddr
        }
        self.to = to
        let from = try container.decodeIfPresent(EthereumAddress.self, forKey: .to)
//        var from: EthereumAddress?
//        if fromString != nil {
//            guard let ethAddr = EthereumAddress(toString) else {throw NervosError.dataError}
//            from = ethAddr
//        }
        self.from = from
        
        let value = try decodeHexToBigUInt(container, key: .value)
        self.value = value
    }
}

extension EthereumTransaction:Decodable {
    enum CodingKeys: String, CodingKey
    {
        case to
        case data
        case input
        case nonce
        case v
        case r
        case s
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let options = try NervosOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var data = try decodeHexToData(container, key: .data, allowOptional: true)
        if data != nil {
            self.data = data!
        } else {
            data = try decodeHexToData(container, key: .input, allowOptional: true)
            if data != nil {
                self.data = data!
            } else {
                throw NervosError.dataError
            }
        }
        
        guard let nonce = try decodeHexToBigUInt(container, key: .nonce) else {throw NervosError.dataError}
        self.nonce = nonce

        guard let v = try decodeHexToBigUInt(container, key: .v) else {throw NervosError.dataError}
        self.v = v
        
        guard let r = try decodeHexToBigUInt(container, key: .r) else {throw NervosError.dataError}
        self.r = r
        
        guard let s = try decodeHexToBigUInt(container, key: .s) else {throw NervosError.dataError}
        self.s = s
        
        if options.value == nil || options.to == nil || options.gasLimit == nil || options.gasPrice == nil{
            throw NervosError.dataError
        }
        self.value = options.value!
        self.to = options.to!
        self.gasPrice = options.gasPrice!
        self.gasLimit = options.gasLimit!
        
        let inferedChainID = self.inferedChainID
        if (self.inferedChainID != nil && self.v >= BigUInt(37)) {
            self.chainID = inferedChainID
        }
    }
}

public struct TransactionDetails: Decodable {
    public var hash: Data
    public var content: Data
    public var blockHash: Data?
    public var blockNumber: BigUInt?
    public var index: BigUInt?
    
    enum CodingKeys: String, CodingKey
    {
        case blockHash
        case blockNumber
        case hash
        case content
        case index
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let blockNumber = try decodeHexToBigUInt(container, key: .blockNumber, allowOptional: true)
        self.blockNumber = blockNumber
        
        let blockHash = try decodeHexToData(container, key: .blockHash, allowOptional: true)
        self.blockHash = blockHash
        
        guard let hash = try decodeHexToData(container, key: .hash) else {throw NervosError.dataError}
        self.hash = hash
        
        guard let content = try decodeHexToData(container, key: .content) else {throw NervosError.dataError}
        self.content = content
        
        let index = try decodeHexToBigUInt(container, key: .index, allowOptional: true)
        self.index = index
    }
}

public struct TransactionReceipt: Decodable {
    public var transactionHash: Data
    public var blockHash: Data
    public var blockNumber: BigUInt
    public var transactionIndex: BigUInt
    public var contractAddress: EthereumAddress?
    public var cumulativeGasUsed: BigUInt
    public var gasUsed: BigUInt
    public var logs: [EventLog]
    public var status: TXStatus
    public var logsBloom: EthereumBloomFilter?
    
    public enum TXStatus {
        case ok
        case failed
        case notYetProcessed
    }
    
    enum CodingKeys: String, CodingKey
    {
        case blockHash
        case blockNumber
        case transactionHash
        case transactionIndex
        case contractAddress
        case cumulativeGasUsed
        case gasUsed
        case logs
        case logsBloom
        case status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let blockNumber = try decodeHexToBigUInt(container, key: .blockNumber) else {throw NervosError.dataError}
        self.blockNumber = blockNumber
        
        guard let blockHash = try decodeHexToData(container, key: .blockHash) else {throw NervosError.dataError}
        self.blockHash = blockHash
        
        guard let transactionIndex = try decodeHexToBigUInt(container, key: .transactionIndex) else {throw NervosError.dataError}
        self.transactionIndex = transactionIndex
        
        guard let transactionHash = try decodeHexToData(container, key: .transactionHash) else {throw NervosError.dataError}
        self.transactionHash = transactionHash
        
        let contractAddress = try container.decodeIfPresent(EthereumAddress.self, forKey: .contractAddress)
        if contractAddress != nil {
            self.contractAddress = contractAddress
        }
        
        guard let cumulativeGasUsed = try decodeHexToBigUInt(container, key: .cumulativeGasUsed) else {throw NervosError.dataError}
        self.cumulativeGasUsed = cumulativeGasUsed
        
        guard let gasUsed = try decodeHexToBigUInt(container, key: .gasUsed) else {throw NervosError.dataError}
        self.gasUsed = gasUsed
        
        
        let status = try decodeHexToBigUInt(container, key: .status, allowOptional: true)
        if (status == nil) {
            self.status = TXStatus.notYetProcessed
        } else if status == 1 {
            self.status = TXStatus.ok
        } else {
            self.status = TXStatus.failed
        }
        
        let logsData = try decodeHexToData(container, key: .logsBloom, allowOptional: true)
        if logsData != nil && logsData!.count > 0 {
            self.logsBloom = EthereumBloomFilter(logsData!)
        }
        
        let logs = try container.decode([EventLog].self, forKey: .logs)
        self.logs = logs
    }
    
    
    public init(transactionHash: Data, blockHash: Data, blockNumber: BigUInt, transactionIndex: BigUInt, contractAddress: EthereumAddress?, cumulativeGasUsed: BigUInt, gasUsed: BigUInt, logs: [EventLog], status: TXStatus, logsBloom: EthereumBloomFilter?) {
        self.transactionHash = transactionHash
        self.blockHash = blockHash
        self.blockNumber = blockNumber
        self.transactionIndex = transactionIndex
        self.contractAddress = contractAddress
        self.cumulativeGasUsed = cumulativeGasUsed
        self.gasUsed = gasUsed
        self.logs = logs
        self.status = status
        self.logsBloom = logsBloom
    }
    
    public init? (_ json: [String: AnyObject]) {
        guard let th = json["transactionHash"] as? String else {return nil}
        guard let transactionHash = Data.fromHex(th) else {return nil}
        self.transactionHash = transactionHash
        guard let bh = json["blockHash"] as? String else {return nil}
        guard let blockHash = Data.fromHex(bh) else {return nil}
        self.blockHash = blockHash
        guard let bn = json["blockNumber"] as? String else {return nil}
        guard let ti = json["transactionIndex"] as? String else {return nil}
        let ca = json["contractAddress"] as? String
        guard let cgu = json["cumulativeGasUsed"] as? String else {return nil}
        guard let gu = json["gasUsed"] as? String else {return nil}
        guard let ls = json["logs"] as? Array<[String:AnyObject]> else {return nil}
        let lbl = json["logsBloom"] as? String
        let st = json["status"] as? String
    
        guard let bnUnwrapped = BigUInt(bn.stripHexPrefix(), radix: 16) else {return nil}
        blockNumber = bnUnwrapped
        guard let tiUnwrapped = BigUInt(ti.stripHexPrefix(), radix: 16) else {return nil}
        transactionIndex = tiUnwrapped
        if ca != nil {
            contractAddress = EthereumAddress(ca!.addHexPrefix())
        }
        guard let cguUnwrapped = BigUInt(cgu.stripHexPrefix(), radix: 16) else {return nil}
        cumulativeGasUsed = cguUnwrapped
        guard let guUnwrapped = BigUInt(gu.stripHexPrefix(), radix: 16) else {return nil}
        gasUsed = guUnwrapped
        var allLogs = [EventLog]()
        for l in ls {
            guard let log = EventLog(l) else {return nil}
            allLogs.append(log)
        }
        logs = allLogs
        if (st == nil) {
            status = TXStatus.notYetProcessed
        } else if st == "0x1" {
            status = TXStatus.ok
        } else {
            status = TXStatus.failed
        }
        if lbl != nil {
            let logsData = Data.fromHex(lbl!)
            if logsData != nil && logsData!.count > 0 {
                logsBloom = EthereumBloomFilter(logsData!)
            }
        }
    }
    
    static func notProcessed(transactionHash: Data) -> TransactionReceipt {
        let receipt = TransactionReceipt.init(transactionHash: transactionHash, blockHash: Data(), blockNumber: BigUInt(0), transactionIndex: BigUInt(0), contractAddress: nil, cumulativeGasUsed: BigUInt(0), gasUsed: BigUInt(0), logs: [EventLog](), status: .notYetProcessed, logsBloom: nil)
        return receipt
    }
}

extension EthereumAddress: Decodable, Encodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self.init(stringValue)!
    }
    public func encode(to encoder: Encoder) throws {
        let value = self.address.lowercased()
        var signleValuedCont = encoder.singleValueContainer()
        try signleValuedCont.encode(value)
    }
}

public struct EventLog : Decodable {
    public var address: EthereumAddress
    public var blockHash: Data
    public var blockNumber: BigUInt
    public var data: Data
    public var logIndex: BigUInt
    public var removed: Bool
    public var topics: [Data]
    public var transactionHash: Data
    public var transactionIndex: BigUInt
    
    
//    address = 0x53066cddbc0099eb6c96785d9b3df2aaeede5da3;
//    blockHash = 0x779c1f08f2b5252873f08fd6ec62d75bb54f956633bbb59d33bd7c49f1a3d389;
//    blockNumber = 0x4f58f8;
//    data = 0x0000000000000000000000000000000000000000000000004563918244f40000;
//    logIndex = 0x84;
//    removed = 0;
//    topics =     (
//    0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
//    0x000000000000000000000000efdcf2c36f3756ce7247628afdb632fa4ee12ec5,
//    0x000000000000000000000000d5395c132c791a7f46fa8fc27f0ab6bacd824484
//    );
//    transactionHash = 0x9f7bb2633abb3192d35f65e50a96f9f7ca878fa2ee7bf5d3fca489c0c60dc79a;
//    transactionIndex = 0x99;
    
    enum CodingKeys: String, CodingKey
    {
        case address
        case blockHash
        case blockNumber
        case data
        case logIndex
        case removed
        case topics
        case transactionHash
        case transactionIndex
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let address = try container.decode(EthereumAddress.self, forKey: .address)
        self.address = address
        
        guard let blockNumber = try decodeHexToBigUInt(container, key: .blockNumber) else {throw NervosError.dataError}
        self.blockNumber = blockNumber
        
        guard let blockHash = try decodeHexToData(container, key: .blockHash) else {throw NervosError.dataError}
        self.blockHash = blockHash
        
        guard let transactionIndex = try decodeHexToBigUInt(container, key: .transactionIndex) else {throw NervosError.dataError}
        self.transactionIndex = transactionIndex
        
        guard let transactionHash = try decodeHexToData(container, key: .transactionHash) else {throw NervosError.dataError}
        self.transactionHash = transactionHash
    
        guard let data = try decodeHexToData(container, key: .data) else {throw NervosError.dataError}
        self.data = data
        
        guard let logIndex = try decodeHexToBigUInt(container, key: .logIndex) else {throw NervosError.dataError}
        self.logIndex = logIndex
        
        let removed = try decodeHexToBigUInt(container, key: .removed, allowOptional: true)
        if (removed == 1) {
            self.removed = true
        } else {
            self.removed = false
        }
    
        let topicsStrings = try container.decode([String].self, forKey: .topics)
        var allTopics = [Data]()
        for top in topicsStrings {
            guard let topic = Data.fromHex(top) else {throw NervosError.dataError}
            allTopics.append(topic)
        }
        self.topics = allTopics
    }
    
    
    public init? (_ json: [String: AnyObject]) {
        guard let ad = json["address"] as? String else {return nil}
        guard let d = json["data"] as? String else {return nil}
        guard let li = json["logIndex"] as? String else {return nil}
        let rm = json["removed"] as? Int ?? 0
        guard let tpc = json["topics"] as? [String] else {return nil}
        guard let addr = EthereumAddress(ad) else {return nil}
        address = addr
        guard let txhash = json["transactionHash"] as? String else{return nil}
        let hash = Data.fromHex(txhash)
        if hash != nil {
            transactionHash = hash!
        } else {
            transactionHash = Data()
        }
        data = Data.fromHex(d)!
        guard let liUnwrapped = BigUInt(li.stripHexPrefix(), radix: 16) else {return nil}
        logIndex = liUnwrapped
        removed = rm == 1 ? true : false
        var tops = [Data]()
        for t in tpc {
            guard let topic = Data.fromHex(t) else {return nil}
            tops.append(topic)
        }
        topics = tops
        // TODO
        blockNumber = 0
        blockHash = Data()
        transactionIndex = 0
    }
}

public enum TransactionInBlock:Decodable {
    case hash(Data)
    case transaction(EthereumTransaction)
    case null
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let string = try? value.decode(String.self) {
            guard let d = Data.fromHex(string) else {throw NervosError.dataError}
            self = .hash(d)
        } else if let dict = try? value.decode([String:String].self) {
//            guard let t = try? EthereumTransaction(from: decoder) else {throw NervosError.dataError}
            guard let t = EthereumTransaction.fromJSON(dict) else {throw NervosError.dataError}
            self = .transaction(t)
        } else {
            self = .null
        }
    }
    
    
    public init?(_ data: AnyObject) {
        if let string = data as? String {
            guard let d = Data.fromHex(string) else {return nil}
            self = .hash(d)
        } else if let dict = data as? [String:AnyObject] {
            guard let t = EthereumTransaction.fromJSON(dict) else {return nil}
            self = .transaction(t)
        } else {
            return nil
        }
    }
}

public struct Block:Decodable {
    public var number: BigUInt
    public var hash: Data
    public var parentHash: Data
    public var nonce: Data?
    public var sha3Uncles: Data
    public var logsBloom: EthereumBloomFilter?
    public var transactionsRoot: Data
    public var stateRoot: Data
    public var receiptsRoot: Data
    public var miner: EthereumAddress?
    public var difficulty: BigUInt
    public var totalDifficulty: BigUInt
    public var extraData: Data
    public var size: BigUInt
    public var gasLimit: BigUInt
    public var gasUsed: BigUInt
    public var timestamp: Date
    public var transactions: [TransactionInBlock]
    public var uncles: [Data]
    
    enum CodingKeys: String, CodingKey
    {
        case number
        case hash
        case parentHash
        case nonce
        case sha3Uncles
        case logsBloom
        case transactionsRoot
        case stateRoot
        case receiptsRoot
        case miner
        case difficulty
        case totalDifficulty
        case extraData
        case size
        case gasLimit
        case gasUsed
        case timestamp
        case transactions
        case uncles
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let number = try decodeHexToBigUInt(container, key: .number) else {throw NervosError.dataError}
        self.number = number
        
        guard let hash = try decodeHexToData(container, key: .hash) else {throw NervosError.dataError}
        self.hash = hash
        
        guard let parentHash = try decodeHexToData(container, key: .parentHash) else {throw NervosError.dataError}
        self.parentHash = parentHash
        
        let nonce = try decodeHexToData(container, key: .nonce, allowOptional: true)
        self.nonce = nonce
        
        guard let sha3Uncles = try decodeHexToData(container, key: .sha3Uncles) else {throw NervosError.dataError}
        self.sha3Uncles = sha3Uncles
        
        let logsBloomData = try decodeHexToData(container, key: .logsBloom, allowOptional: true)
        var bloom:EthereumBloomFilter?
        if logsBloomData != nil {
            bloom = EthereumBloomFilter(logsBloomData!)
        }
        self.logsBloom = bloom
        
        guard let transactionsRoot = try decodeHexToData(container, key: .transactionsRoot) else {throw NervosError.dataError}
        self.transactionsRoot = transactionsRoot
        
        guard let stateRoot = try decodeHexToData(container, key: .stateRoot) else {throw NervosError.dataError}
        self.stateRoot = stateRoot
        
        guard let receiptsRoot = try decodeHexToData(container, key: .receiptsRoot) else {throw NervosError.dataError}
        self.receiptsRoot = receiptsRoot
        
        let minerAddress = try? container.decode(String.self, forKey: .miner)
        var miner:EthereumAddress?
        if minerAddress != nil {
            guard let minr = EthereumAddress(minerAddress!) else {throw NervosError.dataError}
            miner = minr
        }
        self.miner = miner
        
        guard let difficulty = try decodeHexToBigUInt(container, key: .difficulty) else {throw NervosError.dataError}
        self.difficulty = difficulty
        
        guard let totalDifficulty = try decodeHexToBigUInt(container, key: .totalDifficulty) else {throw NervosError.dataError}
        self.totalDifficulty = totalDifficulty
        
        guard let extraData = try decodeHexToData(container, key: .extraData) else {throw NervosError.dataError}
        self.extraData = extraData
        
        guard let size = try decodeHexToBigUInt(container, key: .size) else {throw NervosError.dataError}
        self.size = size
        
        guard let gasLimit = try decodeHexToBigUInt(container, key: .gasLimit) else {throw NervosError.dataError}
        self.gasLimit = gasLimit
        
        guard let gasUsed = try decodeHexToBigUInt(container, key: .gasUsed) else {throw NervosError.dataError}
        self.gasUsed = gasUsed
        
        let timestampString = try container.decode(String.self, forKey: .timestamp).stripHexPrefix()
        guard let timestampInt = UInt64(timestampString, radix: 16) else {throw NervosError.dataError}
        let timestamp = Date(timeIntervalSince1970: TimeInterval(timestampInt))
        self.timestamp = timestamp
        
        let transactions = try container.decode([TransactionInBlock].self, forKey: .transactions)
        self.transactions = transactions
        
        let unclesStrings = try container.decode([String].self, forKey: .uncles)
        var uncles = [Data]()
        for str in unclesStrings {
            guard let d = Data.fromHex(str) else {throw NervosError.dataError}
            uncles.append(d)
        }
        self.uncles = uncles
    }
}

public struct NervosBlock:Decodable{
    public var version: BigUInt
    public var hash: Data
    public var header: NervosHeader
    public var body:NervosBody
    
    enum CodingKeys: String, CodingKey
    {
        case version
        case hash
        case header = "header"
        case body = "body"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let version = try decodeIntToBigUInt(container, key: .version) else {
            throw NervosError.dataError
        }
        self.version = version
        
        guard let hash = try decodeHexToData(container, key: .hash) else {throw NervosError.dataError}
        self.hash = hash
        
        let header = try container.decode(NervosHeader.self, forKey: .header)
        self.header = header
        
        let body = try container.decode(NervosBody.self, forKey: .body)
        self.body = body
    }
}

public struct NervosHeader:Decodable{
    public var timestamp: BigUInt
    public var prevHash: Data
    public var proof: Tendermint
    public var stateRoot: Data
    public var transactionsRoot: Data
    public var receiptsRoot: Data
    public var gasUsed: Data
    public var number: Data
    public var proposer: Data
    
    enum CodingKeys: String, CodingKey
    {
        case timestamp
        case prevHash
        case proof = "proof"
        case stateRoot
        case transactionsRoot
        case receiptsRoot
        case gasUsed
        case number
        case proposer
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let timestamp = try decodeIntToBigUInt(container, key: .timestamp) else {throw NervosError.dataError}
        print(timestamp)
        self.timestamp = timestamp
        
        guard let prevHash = try decodeHexToData(container, key: .prevHash) else {throw NervosError.dataError}
        self.prevHash = prevHash
        
        let proof = try container.decode(Tendermint.self, forKey: .proof)
        self.proof = proof
        
        guard let stateRoot = try decodeHexToData(container, key: .stateRoot) else {throw NervosError.dataError}
        self.stateRoot = stateRoot
        
        guard let transactionsRoot = try decodeHexToData(container, key: .transactionsRoot) else {throw NervosError.dataError}
        self.transactionsRoot = transactionsRoot
        
        guard let receiptsRoot = try decodeHexToData(container, key: .receiptsRoot) else {throw NervosError.dataError}
        self.receiptsRoot = receiptsRoot
        
        guard let gasUsed = try decodeHexToData(container, key: .gasUsed) else {throw NervosError.dataError}
        self.gasUsed = gasUsed
        
        guard let number = try decodeHexToData(container, key: .number) else {throw NervosError.dataError}
        self.number = number
        
        guard let proposer = try decodeHexToData(container, key: .proposer) else {throw NervosError.dataError}
        self.proposer = proposer
    }
}
 
 public struct Tendermint:Decodable{
    public var Tendermint:NervosProof
    enum CodingKeys: String, CodingKey{
        case Tendermint
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let Tendermint = try container.decode(NervosProof.self, forKey: .Tendermint)
        self.Tendermint = Tendermint
    }
 }

public struct NervosProof:Decodable{
    public var proposal: Data
    public var height: BigUInt
    public var round: BigUInt
    public var commits:[Data:Data]
    
    enum CodingKeys: String, CodingKey{
        case proposal = "proposal"
        case height
        case round
        case commits
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let proposal = try decodeHexToData(container, key: .proposal) else {throw NervosError.dataError}
        self.proposal = proposal
        
        guard let height = try decodeIntToBigUInt(container, key: .height) else {throw NervosError.dataError}
        self.height = height
        
        guard let round = try decodeIntToBigUInt(container, key: .round) else {throw NervosError.dataError}
        self.round = round
        
        let commitsStrings = try container.decode([String:String].self, forKey: .commits)
        var commits = [Data:Data]()
        
        for str in commitsStrings {
            guard let d = Data.fromHex(str.key) else {throw NervosError.dataError}
            guard let c = Data.fromHex(str.value) else {throw NervosError.dataError}
            commits[d] = c
        }
        self.commits = commits
    }
    
}

public struct NervosBody:Decodable{
    public var transactions:[BlockTransaction]? = []
    enum CodingKeys: String, CodingKey{
        case transactions = "transactions"
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let transactions = try container.decode([BlockTransaction]?.self, forKey: .transactions)
        self.transactions = transactions
    }
}
public struct BlockTransaction:Decodable{
    public var hash: Data?
    public var content: Data?
    enum CodingKeys: String, CodingKey{
        case hash
        case content
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let hash = try decodeHexToData(container, key: .hash) else {throw NervosError.dataError}
        self.hash = hash
        
        guard let content = try decodeHexToData(container, key: .content) else {throw NervosError.dataError}
        self.content = content
    }
}


public struct EventParserResult:EventParserResultProtocol {
    public var eventName: String
    public var transactionReceipt: TransactionReceipt?
    public var contractAddress: EthereumAddress
    public var decodedResult: [String:Any]
    public var eventLog: EventLog?
    
    public init (eventName: String, transactionReceipt: TransactionReceipt?, contractAddress: EthereumAddress, decodedResult: [String:Any]) {
        self.eventName = eventName
        self.transactionReceipt = transactionReceipt
        self.contractAddress = contractAddress
        self.decodedResult = decodedResult
        self.eventLog = nil
    }
}

 public struct MetaData:Decodable{
    public var chainId: BigUInt
    public var chainName: String
    public var Operator: String
    public var website: String
    public var genesisTimestamp: BigUInt
    public var validators: [String]
    public var blockInterval:BigUInt
    public var tokenName: String
    public var tokenSymbol: String
    public var tokenAvatar: String
    
    enum CodingKeys: String, CodingKey{
        case chainId
        case chainName
        case Operator = "operator"
        case website
        case genesisTimestamp
        case validators
        case blockInterval
        case tokenName
        case tokenSymbol
        case tokenAvatar
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let chainId = try decodeIntToBigUInt(container, key: .chainId) else {throw NervosError.dataError}
        self.chainId = chainId
        
        let chainname = try container.decode(String.self, forKey: .chainName)
        self.chainName = chainname
        
        let Operator = try container.decode(String.self, forKey: .Operator)
        self.Operator = Operator
        
        let website = try container.decode(String.self, forKey: .website)
        self.website = website
        
        guard let genesisTimestamp = try decodeIntToBigUInt(container, key: .genesisTimestamp) else {throw NervosError.dataError}
        self.genesisTimestamp = genesisTimestamp
        
        let validators = try container.decode([String].self, forKey: .validators)
        self.validators = validators

        guard let blockInterval = try decodeIntToBigUInt(container, key: .blockInterval) else {throw NervosError.dataError}
        self.blockInterval = blockInterval
        
        let token_name = try container.decode(String.self, forKey: .tokenName)
        self.tokenName = token_name
        
        let token_symbol = try container.decode(String.self, forKey: .tokenSymbol)
        self.tokenSymbol = token_symbol
        
        let token_avatar = try container.decode(String.self, forKey: .tokenAvatar)
        self.tokenAvatar = token_avatar
        
    }
 }
 
 
 
 
public struct TransactionSendingResult {
    public var transaction: EthereumTransaction
    public var hash: String
}

public struct NervosTransactionSendingResult {
    public var transaction: NervosTransaction
    public var hash: String
}


