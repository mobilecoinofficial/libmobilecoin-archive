//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: view.proto
//

//
// Copyright 2023, MobileCoin Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
#if canImport(SwiftProtobuf)
import SwiftProtobuf
#endif


//// A single Duplex streaming API that allows clients to authorize with Fog View and
//// query it for TxOuts.
///
/// Usage: instantiate `FogView_FogViewRouterAPIRestClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewRouterAPIRestClientProtocol: HTTPClient {
  var serviceName: String { get }

  func request(
    _ request: FogView_FogViewRouterRequest,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<FogView_FogViewRouterRequest, FogView_FogViewRouterResponse>
}

extension FogView_FogViewRouterAPIRestClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewRouterAPI"
  }

  /// Unary call to request
  ///
  /// - Parameters:
  ///   - request: Request to send to request.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func request(
    _ request: FogView_FogViewRouterRequest,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<FogView_FogViewRouterRequest, FogView_FogViewRouterResponse> {
    return self.makeUnaryCall(
      path: FogView_FogViewRouterAPIClientMetadata.Methods.request.path,
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }
}

public final class FogView_FogViewRouterAPIRestClient: FogView_FogViewRouterAPIRestClientProtocol {
  public var defaultHTTPCallOptions: HTTPCallOptions

  /// Creates a client for the fog_view.FogViewRouterAPI service.
  ///
  /// - Parameters:
  ///   - defaultHTTPCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(
    defaultHTTPCallOptions: HTTPCallOptions = HTTPCallOptions()
  ) {
    self.defaultHTTPCallOptions = defaultHTTPCallOptions
  }
}

public enum FogView_FogViewRouterAPIClientMetadata {
  public static let serviceDescriptor = HTTPServiceDescriptor(
    name: "FogViewRouterAPI",
    fullName: "fog_view.FogViewRouterAPI",
    methods: [
      FogView_FogViewRouterAPIClientMetadata.Methods.request,
    ]
  )

  public enum Methods {
    public static let request = HTTPMethodDescriptor(
      name: "request",
      path: "/fog_view.FogViewRouterAPI/request",
      type: HTTPCallType.unary
    )
  }
}

/// Usage: instantiate `FogView_FogViewRouterAdminAPIRestClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewRouterAdminAPIRestClientProtocol: HTTPClient {
  var serviceName: String { get }

  func addShard(
    _ request: FogCommon_AddShardRequest,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<FogCommon_AddShardRequest, SwiftProtobuf.Google_Protobuf_Empty>
}

extension FogView_FogViewRouterAdminAPIRestClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewRouterAdminAPI"
  }

  /// Adds a shard to the Fog View Router's list of shards to query.
  ///
  /// - Parameters:
  ///   - request: Request to send to addShard.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func addShard(
    _ request: FogCommon_AddShardRequest,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<FogCommon_AddShardRequest, SwiftProtobuf.Google_Protobuf_Empty> {
    return self.makeUnaryCall(
      path: FogView_FogViewRouterAdminAPIClientMetadata.Methods.addShard.path,
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }
}

public final class FogView_FogViewRouterAdminAPIRestClient: FogView_FogViewRouterAdminAPIRestClientProtocol {
  public var defaultHTTPCallOptions: HTTPCallOptions

  /// Creates a client for the fog_view.FogViewRouterAdminAPI service.
  ///
  /// - Parameters:
  ///   - defaultHTTPCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(
    defaultHTTPCallOptions: HTTPCallOptions = HTTPCallOptions()
  ) {
    self.defaultHTTPCallOptions = defaultHTTPCallOptions
  }
}

public enum FogView_FogViewRouterAdminAPIClientMetadata {
  public static let serviceDescriptor = HTTPServiceDescriptor(
    name: "FogViewRouterAdminAPI",
    fullName: "fog_view.FogViewRouterAdminAPI",
    methods: [
      FogView_FogViewRouterAdminAPIClientMetadata.Methods.addShard,
    ]
  )

  public enum Methods {
    public static let addShard = HTTPMethodDescriptor(
      name: "addShard",
      path: "/fog_view.FogViewRouterAdminAPI/addShard",
      type: HTTPCallType.unary
    )
  }
}

//// Fulfills requests sent directly by a Fog client, e.g. a mobile phone using the SDK.
///
/// Usage: instantiate `FogView_FogViewAPIRestClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewAPIRestClientProtocol: HTTPClient {
  var serviceName: String { get }

  func auth(
    _ request: Attest_AuthMessage,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage>

  func query(
    _ request: Attest_Message,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<Attest_Message, Attest_Message>
}

extension FogView_FogViewAPIRestClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewAPI"
  }

  //// This is called to perform IX key exchange with the enclave before calling GetOutputs.
  ///
  /// - Parameters:
  ///   - request: Request to send to Auth.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func auth(
    _ request: Attest_AuthMessage,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage> {
    return self.makeUnaryCall(
      path: FogView_FogViewAPIClientMetadata.Methods.auth.path,
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }

  //// Input should be an encrypted QueryRequest, result is an encrypted QueryResponse
  ///
  /// - Parameters:
  ///   - request: Request to send to Query.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func query(
    _ request: Attest_Message,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<Attest_Message, Attest_Message> {
    return self.makeUnaryCall(
      path: FogView_FogViewAPIClientMetadata.Methods.query.path,
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }
}

public final class FogView_FogViewAPIRestClient: FogView_FogViewAPIRestClientProtocol {
  public var defaultHTTPCallOptions: HTTPCallOptions

  /// Creates a client for the fog_view.FogViewAPI service.
  ///
  /// - Parameters:
  ///   - defaultHTTPCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(
    defaultHTTPCallOptions: HTTPCallOptions = HTTPCallOptions()
  ) {
    self.defaultHTTPCallOptions = defaultHTTPCallOptions
  }
}

public enum FogView_FogViewAPIClientMetadata {
  public static let serviceDescriptor = HTTPServiceDescriptor(
    name: "FogViewAPI",
    fullName: "fog_view.FogViewAPI",
    methods: [
      FogView_FogViewAPIClientMetadata.Methods.auth,
      FogView_FogViewAPIClientMetadata.Methods.query,
    ]
  )

  public enum Methods {
    public static let auth = HTTPMethodDescriptor(
      name: "Auth",
      path: "/fog_view.FogViewAPI/Auth",
      type: HTTPCallType.unary
    )

    public static let query = HTTPMethodDescriptor(
      name: "Query",
      path: "/fog_view.FogViewAPI/Query",
      type: HTTPCallType.unary
    )
  }
}

//// Fulfills requests sent by the Fog View Router. This is not meant to fulfill requests sent directly by the client.
///
/// Usage: instantiate `FogView_FogViewStoreAPIRestClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewStoreAPIRestClientProtocol: HTTPClient {
  var serviceName: String { get }

  func auth(
    _ request: Attest_AuthMessage,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage>

  func multiViewStoreQuery(
    _ request: FogView_MultiViewStoreQueryRequest,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<FogView_MultiViewStoreQueryRequest, FogView_MultiViewStoreQueryResponse>
}

extension FogView_FogViewStoreAPIRestClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewStoreAPI"
  }

  //// This is called to perform IX key exchange with the enclave before calling GetOutputs.
  ///
  /// - Parameters:
  ///   - request: Request to send to Auth.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func auth(
    _ request: Attest_AuthMessage,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage> {
    return self.makeUnaryCall(
      path: FogView_FogViewStoreAPIClientMetadata.Methods.auth.path,
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }

  //// Input should be an encrypted MultiViewStoreQueryRequest, result is an encrypted QueryResponse.
  ///
  /// - Parameters:
  ///   - request: Request to send to MultiViewStoreQuery.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func multiViewStoreQuery(
    _ request: FogView_MultiViewStoreQueryRequest,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<FogView_MultiViewStoreQueryRequest, FogView_MultiViewStoreQueryResponse> {
    return self.makeUnaryCall(
      path: FogView_FogViewStoreAPIClientMetadata.Methods.multiViewStoreQuery.path,
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }
}

public final class FogView_FogViewStoreAPIRestClient: FogView_FogViewStoreAPIRestClientProtocol {
  public var defaultHTTPCallOptions: HTTPCallOptions

  /// Creates a client for the fog_view.FogViewStoreAPI service.
  ///
  /// - Parameters:
  ///   - defaultHTTPCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(
    defaultHTTPCallOptions: HTTPCallOptions = HTTPCallOptions()
  ) {
    self.defaultHTTPCallOptions = defaultHTTPCallOptions
  }
}

public enum FogView_FogViewStoreAPIClientMetadata {
  public static let serviceDescriptor = HTTPServiceDescriptor(
    name: "FogViewStoreAPI",
    fullName: "fog_view.FogViewStoreAPI",
    methods: [
      FogView_FogViewStoreAPIClientMetadata.Methods.auth,
      FogView_FogViewStoreAPIClientMetadata.Methods.multiViewStoreQuery,
    ]
  )

  public enum Methods {
    public static let auth = HTTPMethodDescriptor(
      name: "Auth",
      path: "/fog_view.FogViewStoreAPI/Auth",
      type: HTTPCallType.unary
    )

    public static let multiViewStoreQuery = HTTPMethodDescriptor(
      name: "MultiViewStoreQuery",
      path: "/fog_view.FogViewStoreAPI/MultiViewStoreQuery",
      type: HTTPCallType.unary
    )
  }
}

