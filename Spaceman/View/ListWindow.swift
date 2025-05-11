import SwiftUI

class ListWindow: NSWindow {
    private static let windowWidth: CGFloat = 250
    private static let leftMargin: CGFloat = 32
    init(spaceObserver: SpaceObserver) {
        let windowWidth = Self.windowWidth
        let windowHeight: CGFloat = 400

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect.zero
        let initialX = screenFrame.maxX - Self.leftMargin
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
                strongSelf.onHeightChange(newHeight: CGSize(width: Self.windowWidth, height: heightValue))
            }
        }))

        // Tracking area setup
        setupTrackingArea()

        // Observe contentView bounds changes
        NotificationCenter.default.addObserver(self, selector: #selector(contentViewFrameDidChange), name: NSView.frameDidChangeNotification, object: self.contentView)
        self.contentView?.postsFrameChangedNotifications = true

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
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        if originalFrame == nil {
            originalFrame = self.frame
        }
        shiftWindowLeft(by: hoverShiftAmount)
    }
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        restoreWindowPosition()
    }
    private func shiftWindowLeft(by amount: CGFloat) {
        let newOriginX = self.frame.origin.x - amount
        let newFrame = NSRect(x: newOriginX, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        DispatchQueue.main.async {
            self.setFrame(newFrame, display: true, animate: true)
        }
    }
    private func restoreWindowPosition() {
        guard let original = originalFrame else { return }
        DispatchQueue.main.async {
            self.setFrame(original, display: true, animate: true)
        }
        originalFrame = nil
    }
    private var trackingArea: NSTrackingArea?
    private var originalFrame: NSRect?
    private var hoverShiftAmount: CGFloat {
        return Self.windowWidth - Self.leftMargin
    }
    private func setupTrackingArea() {
        if let trackingArea = trackingArea {
            self.contentView?.removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(rect: self.contentView?.bounds ?? .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        self.contentView?.addTrackingArea(area)
        trackingArea = area
    }
    @objc private func contentViewFrameDidChange() {
        setupTrackingArea()
    }
}
