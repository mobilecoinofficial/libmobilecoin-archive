//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct HTTPServiceDescriptor: Sendable {
    public let name: String
    public let fullName: String
    public let methods: [HTTPMethodDescriptor]
}
