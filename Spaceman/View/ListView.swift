import SwiftUI

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    private let spaceObserver: SpaceObserver
    var onHeightChange: (CGFloat) -> Void
    private let minWidth: CGFloat
    @State private var contentHeight: CGFloat = 0
    @State private var selectedWindow: (pid: pid_t, title: String)? = nil
    @State private var hoveredWindow: (pid: pid_t, title: String)? = nil
    
    init(spaceObserver: SpaceObserver, minWidth: CGFloat, onHeightChange: @escaping (CGFloat) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: ListViewModel(spaceObserver: spaceObserver))
        self.spaceObserver = spaceObserver
        self.minWidth = minWidth
        self.onHeightChange = onHeightChange
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.spaces, id: \.spaceID) { space in
                VStack(alignment: .leading) {
                    HStack {
                        Text("S\(space.spaceNumber)")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(space.isCurrentSpace ? .blue : .primary)
                            .padding(.horizontal, 6)

                        Spacer()
                        if space.isFullScreen {
                            Text("Fullscreen")
                                .foregroundColor(.primary)
                                .font(.caption)
                        }
                    }
                    .padding(.top, 8)
//                    .padding(.vertical, 2)

                    
                    if !space.windows.isEmpty {
                        ForEach(space.windows, id: \.title) { window in
                            HStack(spacing: 0) {
                                if let icon = window.appIcon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.leading, -4)
                                        .padding(.horizontal, 8)
                                }
                                Text(window.title)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                            .background(
                                Rectangle()
                                    .fill(hoveredWindow?.pid == window.pid && hoveredWindow?.title == window.title ? Color.blue : Color.clear)
                            )
                            .contentShape(Rectangle())
                            .onHover { isHovered in
                                if isHovered {
                                    hoveredWindow = (window.pid, window.title)
                                } else {
                                    hoveredWindow = nil
                                }
                            }
                            .onTapGesture {
                                selectedWindow = (window.pid, window.title)
                                spaceObserver.activateWindow(pid: window.pid, title: window.title)
                            }
                        }
                    }
                }
            }
        }
        .overlay(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            if height > 0 {
                DispatchQueue.main.async {
                    if self.contentHeight != height {
                        self.contentHeight = height
                        onHeightChange(height)
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .frame(minWidth: minWidth + 50)
        .cornerRadius(5)
    }
}

#Preview {
    ListView(spaceObserver: SpaceObserver(), minWidth: 300, onHeightChange: { height in
        print("ListView height: \(height)")
    })
}
