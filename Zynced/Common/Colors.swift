//
//  Colors.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation

extension CGColor {
  struct StatusColor {
    static var connected: CGColor  { return CGColor(red: 128.0/255.0, green: 192.0/255.0, blue: 44.0/255.0, alpha: 1.0) }
    static var active: CGColor { return CGColor(red: 228.0/255.0, green: 192.0/255.0, blue: 32.0/255.0, alpha: 1.0) }
    static var inactive: CGColor { return CGColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0) }
    static var failed: CGColor { return CGColor(red: 192.0/255.0, green: 44.0/255.0, blue: 71.0/255.0, alpha: 1.0) }
  }
}
