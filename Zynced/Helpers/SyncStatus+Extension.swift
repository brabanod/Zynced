//
//  SyncStatus+Extension.swift
//  Zynced
//
//  Created by Pascal Braband on 03.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import BoteCore

extension SyncStatus {

    func isRunningStatus() -> Bool {
        switch self {
        case .connected, .active, .failed:
            return true
        case .inactive:
            return false
        }
    }
}
