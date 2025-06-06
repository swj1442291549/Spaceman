//
//  SpaceObserver.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation
import ApplicationServices

class SpaceObserver {
    private let workspace = NSWorkspace.shared
    private let conn = _CGSDefaultConnection()
    private let defaults = UserDefaults.standard
    private var delegates: [SpaceObserverDelegate] = []
    private var windowCache: [String: [Window]] = [:] // Cache windows for each space
    
    init() {
        workspace.notificationCenter.addObserver(
            self,
            selector: #selector(updateSpaceInformation),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: workspace)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSpaceInformation),
            name: NSNotification.Name("ButtonPressed"),
            object: nil)
        
        // Request accessibility permissions if needed
        requestAccessibilityPermission()
    }
    
    private func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
    
    func addDelegate(_ delegate: SpaceObserverDelegate) {
        delegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: SpaceObserverDelegate) {
        delegates.removeAll { $0 === delegate as AnyObject }
    }
    
    private func getCurrentWindows() -> [Window] {
        let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as! [[String: Any]]
        var windows: [Window] = []
        
        for window in windowList {
            guard let bounds = window[kCGWindowBounds as String] as? [String: Any],
                  let ownerName = window[kCGWindowOwnerName as String] as? String,
                  let layer = window[kCGWindowLayer as String] as? Int,
                  let alpha = window[kCGWindowAlpha as String] as? Float,
                  let pid = window[kCGWindowOwnerPID as String] as? pid_t
            else {
                continue
            }
            
            // Skip windows that are not visible or are system windows
            if layer != 0 || alpha == 0 || ownerName == "Window Server" {
                continue
            }
            
            let isMinimized = bounds["Height" as String] as? Double == 0
            
            // Get app icon
            var appIcon: NSImage? = nil
            if let app = NSRunningApplication(processIdentifier: pid) {
                appIcon = app.icon
            }
            
            // Get window title using Accessibility API
            var windowTitle = ownerName
            let appElement = AXUIElementCreateApplication(pid)
            var value: AnyObject?
            let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)
            if result == .success,
               let windowList = value as? [AXUIElement] {
                for windowElement in windowList {
                    var titleValue: AnyObject?
                    if AXUIElementCopyAttributeValue(windowElement, kAXTitleAttribute as CFString, &titleValue) == .success,
                       let title = titleValue as? String {
                        windowTitle = title
                        break
                    }
                }
            }
            
            windows.append(Window(
                title: windowTitle,
                appName: ownerName,
                isMinimized: isMinimized,
                appIcon: appIcon,
                pid: pid
            ))
        }
        
        return windows
    }
    
    @objc public func updateSpaceInformation() {
        let displays = CGSCopyManagedDisplaySpaces(conn) as! [NSDictionary]
        var activeSpaceID = -1
        var allSpaces = [Space]()
        var updatedDict = [String: SpaceNameInfo]()
        var globalSpaceNumber = 1
        
        // Get current windows once
        let currentWindows = getCurrentWindows()
        
        for d in displays {
            guard let currentSpaces = d["Current Space"] as? [String: Any],
                  let spaces = d["Spaces"] as? [[String: Any]],
                  let displayID = d["Display Identifier"] as? String
            else {
                continue
            }
            
            activeSpaceID = currentSpaces["ManagedSpaceID"] as! Int
            
            if activeSpaceID == -1 {
                DispatchQueue.main.async {
                    print("Can't find current space")
                }
                return
            }

            for s in spaces {
                let spaceID = String(s["ManagedSpaceID"] as! Int)
                let isCurrentSpace = activeSpaceID == s["ManagedSpaceID"] as! Int
                let isFullScreen = s["TileLayoutManager"] as? [String: Any] != nil
                var desktopNumber : Int?
                if !isFullScreen {
                    desktopNumber = globalSpaceNumber
                }
                var space = Space(displayID: displayID,
                                  spaceID: spaceID,
                                  spaceName: "N/A",
                                  spaceNumber: globalSpaceNumber,
                                  desktopNumber: desktopNumber,
                                  isCurrentSpace: isCurrentSpace,
                                  isFullScreen: isFullScreen)
                
                if let data = defaults.value(forKey:"spaceNames") as? Data,
                   let dict = try? PropertyListDecoder().decode(Dictionary<String, SpaceNameInfo>.self, from: data),
                   let saved = dict[spaceID] {
                    space.spaceName = saved.spaceName
                } else if isFullScreen {
                    if let pid = s["pid"] as? pid_t,
                       let app = NSRunningApplication(processIdentifier: pid),
                       let name = app.localizedName {
                        space.spaceName = name.prefix(3).uppercased()
                    } else {
                        space.spaceName = "FUL"
                    }
                }
                
                // Update windows based on whether this is the current space
                if isCurrentSpace {
                    // Update cache and space windows for current space
                    windowCache[spaceID] = currentWindows
                    space.windows = currentWindows
                } else {
                    // Use cached windows for non-current spaces
                    space.windows = windowCache[spaceID] ?? []
                }
                
                let nameInfo = SpaceNameInfo(spaceNum: globalSpaceNumber, spaceName: space.spaceName)
                updatedDict[spaceID] = nameInfo
                allSpaces.append(space)
                if !isFullScreen {
                    globalSpaceNumber += 1
                }
            }
        }
        
        defaults.set(try? PropertyListEncoder().encode(updatedDict), forKey: "spaceNames")
        for delegate in delegates {
            delegate.didUpdateSpaces(spaces: allSpaces)
        }
    }
    
    func activateWindow(pid: pid_t, title: String) {
        print("Attempting to activate window: \(title) with PID: \(pid)")
        
        // Get all windows
        let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as! [[String: Any]]
        print("Total windows found: \(windowList.count)")
        
        // Find the window with matching title and PID
        for window in windowList {
            guard let windowPid = window[kCGWindowOwnerPID as String] as? pid_t,
                  windowPid == pid
            else {
                continue
            }
            
            print("Found window with matching PID")
            print("Window info: \(window)")
            
            // Get the window's owner application
            if let app = NSRunningApplication(processIdentifier: pid) {
                print("Activating application: \(app.localizedName ?? "unknown")")
                // Activate the application
                app.activate(options: .activateAllWindows)
                
                // Use Accessibility API to get and activate windows
                let appElement = AXUIElementCreateApplication(pid)
                var value: AnyObject?
                let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)
                
                if result == .success,
                   let windowList = value as? [AXUIElement] {
                    print("Found \(windowList.count) windows through Accessibility API")
                    
                    for windowElement in windowList {
                        var titleValue: AnyObject?
                        if AXUIElementCopyAttributeValue(windowElement, kAXTitleAttribute as CFString, &titleValue) == .success,
                           let windowTitle = titleValue as? String {
                            print("Window title from Accessibility API: \(windowTitle)")
                            
                            // Try to bring window to front
                            AXUIElementSetAttributeValue(windowElement, kAXMainAttribute as CFString, true as CFTypeRef)
                            AXUIElementPerformAction(windowElement, kAXRaiseAction as CFString)
                            
                            // Try to focus the window
                            AXUIElementSetAttributeValue(windowElement, kAXFocusedAttribute as CFString, true as CFTypeRef)
                        }
                    }
                }
            }
            break
        }
    }
}

protocol SpaceObserverDelegate: AnyObject {
    func didUpdateSpaces(spaces: [Space])
}
