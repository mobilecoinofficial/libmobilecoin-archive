// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: printable.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Copyright (c) 2018-2022 The MobileCoin Foundation

/// Protos to be used for displaying encoded strings to users

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

//// Message for a payment request, which combines a public address
//// with an a requested payment amount and memo field
public struct Printable_PaymentRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  //// The public address of the user requesting a payment
  public var publicAddress: External_PublicAddress {
    get {return _publicAddress ?? External_PublicAddress()}
    set {_publicAddress = newValue}
  }
  /// Returns true if `publicAddress` has been explicitly set.
  public var hasPublicAddress: Bool {return self._publicAddress != nil}
  /// Clears the value of `publicAddress`. Subsequent reads from it will return its default value.
  public mutating func clearPublicAddress() {self._publicAddress = nil}

  //// The requested value of the payment
  public var value: UInt64 = 0

  //// Any additional text explaining the request
  public var memo: String = String()

  //// Token id to transact in.
  public var tokenID: UInt64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _publicAddress: External_PublicAddress? = nil
}

//// Message encoding a private key and a UTXO, for the purpose of
//// giving someone access to an output. This would most likely be
//// used for gift cards.
public struct Printable_TransferPayload {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  //// [Deprecated] The root entropy, allowing the recipient to spend the money.
  //// This has been replaced by a BIP39 entropy.
  public var rootEntropy: Data = Data()

  //// The public key of the UTXO to spend. This is an optimization, meaning
  //// the recipient does not need to scan the entire ledger.
  public var txOutPublicKey: External_CompressedRistretto {
    get {return _txOutPublicKey ?? External_CompressedRistretto()}
    set {_txOutPublicKey = newValue}
  }
  /// Returns true if `txOutPublicKey` has been explicitly set.
  public var hasTxOutPublicKey: Bool {return self._txOutPublicKey != nil}
  /// Clears the value of `txOutPublicKey`. Subsequent reads from it will return its default value.
  public mutating func clearTxOutPublicKey() {self._txOutPublicKey = nil}

  //// Any additional text explaining the gift
  public var memo: String = String()

  //// BIP39 entropy, allowing the recipient to spend the money.
  //// When deriving an AccountKey from this entropy, account_index is always 0.
  public var bip39Entropy: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _txOutPublicKey: External_CompressedRistretto? = nil
}

//// This wraps all of the above messages using "oneof", allowing us to
//// have a single encoding scheme and extend as necessary simply by adding
//// new messages without breaking backwards compatibility
public struct Printable_PrintableWrapper {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var wrapper: Printable_PrintableWrapper.OneOf_Wrapper? = nil

  public var publicAddress: External_PublicAddress {
    get {
      if case .publicAddress(let v)? = wrapper {return v}
      return External_PublicAddress()
    }
    set {wrapper = .publicAddress(newValue)}
  }

  public var paymentRequest: Printable_PaymentRequest {
    get {
      if case .paymentRequest(let v)? = wrapper {return v}
      return Printable_PaymentRequest()
    }
    set {wrapper = .paymentRequest(newValue)}
  }

  public var transferPayload: Printable_TransferPayload {
    get {
      if case .transferPayload(let v)? = wrapper {return v}
      return Printable_TransferPayload()
    }
    set {wrapper = .transferPayload(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_Wrapper: Equatable {
    case publicAddress(External_PublicAddress)
    case paymentRequest(Printable_PaymentRequest)
    case transferPayload(Printable_TransferPayload)

  #if !swift(>=4.1)
    public static func ==(lhs: Printable_PrintableWrapper.OneOf_Wrapper, rhs: Printable_PrintableWrapper.OneOf_Wrapper) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.publicAddress, .publicAddress): return {
        guard case .publicAddress(let l) = lhs, case .publicAddress(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.paymentRequest, .paymentRequest): return {
        guard case .paymentRequest(let l) = lhs, case .paymentRequest(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.transferPayload, .transferPayload): return {
        guard case .transferPayload(let l) = lhs, case .transferPayload(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "printable"

extension Printable_PaymentRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".PaymentRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "public_address"),
    2: .same(proto: "value"),
    3: .same(proto: "memo"),
    4: .standard(proto: "token_id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._publicAddress) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.value) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.memo) }()
      case 4: try { try decoder.decodeSingularUInt64Field(value: &self.tokenID) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._publicAddress {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if self.value != 0 {
      try visitor.visitSingularUInt64Field(value: self.value, fieldNumber: 2)
    }
    if !self.memo.isEmpty {
      try visitor.visitSingularStringField(value: self.memo, fieldNumber: 3)
    }
    if self.tokenID != 0 {
      try visitor.visitSingularUInt64Field(value: self.tokenID, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Printable_PaymentRequest, rhs: Printable_PaymentRequest) -> Bool {
    if lhs._publicAddress != rhs._publicAddress {return false}
    if lhs.value != rhs.value {return false}
    if lhs.memo != rhs.memo {return false}
    if lhs.tokenID != rhs.tokenID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Printable_TransferPayload: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TransferPayload"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "root_entropy"),
    2: .standard(proto: "tx_out_public_key"),
    3: .same(proto: "memo"),
    4: .standard(proto: "bip39_entropy"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.rootEntropy) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._txOutPublicKey) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.memo) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.bip39Entropy) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.rootEntropy.isEmpty {
      try visitor.visitSingularBytesField(value: self.rootEntropy, fieldNumber: 1)
    }
    try { if let v = self._txOutPublicKey {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.memo.isEmpty {
      try visitor.visitSingularStringField(value: self.memo, fieldNumber: 3)
    }
    if !self.bip39Entropy.isEmpty {
      try visitor.visitSingularBytesField(value: self.bip39Entropy, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Printable_TransferPayload, rhs: Printable_TransferPayload) -> Bool {
    if lhs.rootEntropy != rhs.rootEntropy {return false}
    if lhs._txOutPublicKey != rhs._txOutPublicKey {return false}
    if lhs.memo != rhs.memo {return false}
    if lhs.bip39Entropy != rhs.bip39Entropy {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Printable_PrintableWrapper: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".PrintableWrapper"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "public_address"),
    2: .standard(proto: "payment_request"),
    3: .standard(proto: "transfer_payload"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try {
        var v: External_PublicAddress?
        var hadOneofValue = false
        if let current = self.wrapper {
          hadOneofValue = true
          if case .publicAddress(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.wrapper = .publicAddress(v)
        }
      }()
      case 2: try {
        var v: Printable_PaymentRequest?
        var hadOneofValue = false
        if let current = self.wrapper {
          hadOneofValue = true
          if case .paymentRequest(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.wrapper = .paymentRequest(v)
        }
      }()
      case 3: try {
        var v: Printable_TransferPayload?
        var hadOneofValue = false
        if let current = self.wrapper {
          hadOneofValue = true
          if case .transferPayload(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.wrapper = .transferPayload(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    switch self.wrapper {
    case .publicAddress?: try {
      guard case .publicAddress(let v)? = self.wrapper else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }()
    case .paymentRequest?: try {
      guard case .paymentRequest(let v)? = self.wrapper else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .transferPayload?: try {
      guard case .transferPayload(let v)? = self.wrapper else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Printable_PrintableWrapper, rhs: Printable_PrintableWrapper) -> Bool {
    if lhs.wrapper != rhs.wrapper {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
