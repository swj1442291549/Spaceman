//
//  Space.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation

struct Window {
    let title: String
    let appName: String
    let isMinimized: Bool
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
