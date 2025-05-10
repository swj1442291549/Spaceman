import SwiftUI

class ListWindow: NSWindow {
    init(spaceObserver: SpaceObserver) {
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 400

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect.zero
        let initialX = screenFrame.maxX - 32  // Push half off the right edge
        let initialY = screenFrame.minY + windowHeight / 2

        let initialFrame = NSRect(x: initialX, y: initialY, width: windowWidth, height: windowHeight)

        super.init(
            contentRect: initialFrame,
            styleMask: [ .miniaturizable],
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

        self.contentView = NSHostingView(rootView: ListView(spaceObserver: spaceObserver, onHeightChange: { [weak self] heightValue in
            if let strongSelf = self {
                strongSelf.onHeightChange(newHeight: CGSize(width: windowWidth, height: heightValue))
            }
        }))

        // Force frame after display to avoid automatic repositioning
        DispatchQueue.main.async {
            let adjustedFrame = NSRect(x: initialX, y: initialY, width: windowWidth, height: windowHeight)
            self.setFrame(adjustedFrame, display: true)
        }
    }

    func onHeightChange(newHeight: CGSize) {
        print("onHeightChange called with newHeight: \(newHeight)")
        guard let screenFrame = self.screen?.visibleFrame ?? NSScreen.main?.visibleFrame else {
            print("No screen available for centering.")
            return
        }
        
        // Only update if height is valid
        if newHeight.height <= 0 {
            print("Invalid height value: \(newHeight.height), skipping update")
            return
        }
        
        // Calculate new position to center vertically
        let newOriginY = screenFrame.minY + (screenFrame.height - newHeight.height) / 2
        let newOrigin = CGPoint(x: self.frame.origin.x, y: newOriginY)
        let newFrame = CGRect(origin: newOrigin, size: CGSize(width: self.frame.width, height: newHeight.height))
        
        print("Setting new frame: \(newFrame)")
        // Use main thread to ensure UI updates properly
        DispatchQueue.main.async {
            self.setFrame(newFrame, display: true, animate: true)
        }
    }
}
