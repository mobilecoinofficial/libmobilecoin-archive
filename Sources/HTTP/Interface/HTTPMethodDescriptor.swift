//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct HTTPMethodDescriptor: Sendable {
    let name: String
    let path: String
    let type: HTTPCallType
}
