import SwiftUI

class ListWindow: NSWindow {
    init(spaceObserver: SpaceObserver) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "List"
        self.center()
        self.setFrameAutosaveName("List Window")
        self.isReleasedWhenClosed = false
        self.level = .floating
        self.contentView = NSHostingView(rootView: ListView(spaceObserver: spaceObserver))
    }
} 
