//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: report.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
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
import GRPC
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
import NIO
import SwiftProtobuf


//// The public API for getting reports
///
/// Usage: instantiate `Report_ReportAPIClient`, then call methods of this protocol to make API calls.
public protocol Report_ReportAPIClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Report_ReportAPIClientInterceptorFactoryProtocol? { get }

  func getReports(
    _ request: Report_ReportRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Report_ReportRequest, Report_ReportResponse>
}

extension Report_ReportAPIClientProtocol {
  public var serviceName: String {
    return "report.ReportAPI"
  }

  //// Get all available pubkeys, with Intel SGX reports, fog urls, and expiry info
  ///
  /// - Parameters:
  ///   - request: Request to send to GetReports.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getReports(
    _ request: Report_ReportRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Report_ReportRequest, Report_ReportResponse> {
    return self.makeUnaryCall(
      path: "/report.ReportAPI/GetReports",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetReportsInterceptors() ?? []
    )
  }
}

public protocol Report_ReportAPIClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'getReports'.
  func makeGetReportsInterceptors() -> [ClientInterceptor<Report_ReportRequest, Report_ReportResponse>]
}

public final class Report_ReportAPIClient: Report_ReportAPIClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Report_ReportAPIClientInterceptorFactoryProtocol?

  /// Creates a client for the report.ReportAPI service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Report_ReportAPIClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

