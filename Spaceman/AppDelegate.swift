//
//  AppDelegate.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI
import KeyboardShortcuts
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBar: StatusBar!
    private var spaceObserver: SpaceObserver!
    private var iconCreator: IconCreator!
    private var listWindow: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusBar = StatusBar()
        spaceObserver = SpaceObserver()
        iconCreator = IconCreator()
        
        // Initialize and show the list window
        listWindow = ListWindow(spaceObserver: spaceObserver)
        listWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        spaceObserver.addDelegate(self)
        spaceObserver.updateSpaceInformation()
        KeyboardShortcuts.onKeyUp(for: .refresh) { [] in
            self.spaceObserver.updateSpaceInformation()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
        let icon = iconCreator.getIcon(for: spaces)
        statusBar.updateStatusBar(withIcon: icon)
    }
}

@main
struct SpacemanApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
