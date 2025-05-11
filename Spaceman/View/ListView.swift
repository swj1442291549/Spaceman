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
    @State private var contentHeight: CGFloat = 0
    
    init(spaceObserver: SpaceObserver, onHeightChange: @escaping (CGFloat) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: ListViewModel(spaceObserver: spaceObserver))
        self.spaceObserver = spaceObserver
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
                        Spacer()
                        if space.isFullScreen {
                            Text("Fullscreen")
                                .foregroundColor(.primary)
                                .font(.caption)
                        }
                    }
                    .padding(.top, 8)
                    
                    if !space.windows.isEmpty {
                        ForEach(space.windows, id: \.title) { window in
                            HStack(spacing: 8) {
                                if let icon = window.appIcon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.leading, -4)
                                }
                                Text(window.title)
                                    .lineLimit(1)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.trailing, 0)

                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                spaceObserver.activateWindow(pid: window.pid, title: window.title)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
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
        .frame(minWidth: 300)
        .cornerRadius(5)
    }
}

#Preview {
    ListView(spaceObserver: SpaceObserver(), onHeightChange: { height in
        print("ListView height: \(height)")
    })
}
