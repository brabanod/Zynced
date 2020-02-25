//
//  ConnectionType+Extension.swift
//  Zynced
//
//  Created by Pascal Braband on 25.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation
import BoteCore

extension ConnectionType {
    
    func toString() -> String {
        switch self {
        case .local: return NSLocalizedString("Local", comment: "Connection name for Local")
        case .sftp: return NSLocalizedString("SFTP", comment: "Connection name for SFTP")
        }
    }
}
