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
        self.isReleasedWhenClosed = false
        self.level = .floating
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        self.contentView = NSHostingView(rootView: ListView(spaceObserver: spaceObserver))
    }
    
    func onHeightChange(newHeight: CGSize) {
        print("onHeightChange called with newHeight: \(newHeight)")
        guard let screenFrame = self.screen?.visibleFrame ?? NSScreen.main?.visibleFrame else {
            print("No screen available for centering.")
            return
        }
        let newOriginY = screenFrame.origin.y + (screenFrame.height - newHeight.height) / 2
        let newOrigin = CGPoint(x: self.frame.origin.x, y: newOriginY)
        let newFrame = CGRect(origin: newOrigin, size: CGSize(width: self.frame.width, height: newHeight.height))
        print("Setting new frame: \(newFrame)")
        self.setFrame(newFrame, display: true, animate: true)
    }
}
