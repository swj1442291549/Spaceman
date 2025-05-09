//
//  Space.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation
import AppKit

struct Window {
    let title: String
    let appName: String
    let isMinimized: Bool
    let appIcon: NSImage?
    let pid: pid_t
}

struct Space {
    var displayID: String
    var spaceID: String
    var spaceName: String
    var spaceNumber: Int
    var desktopNumber: Int?
    var isCurrentSpace: Bool
    var isFullScreen: Bool
    var windows: [Window] = []
}
