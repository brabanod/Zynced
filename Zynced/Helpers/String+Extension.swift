//
//  String+Extension.swift
//  Zynced
//
//  Created by Pascal Braband on 09.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation

extension String {
    
    
    func replaceHomeDirectory() -> String {
        // Replace the home directory with ~
        let homePath = FileManager.default.homeDirectoryForCurrentUser.absoluteString.dropFirst("file://".count)
        return self.replacingOccurrences(of: homePath, with: "~/")
    }
}
