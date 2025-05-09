import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    private let spaceObserver: SpaceObserver
    
    init(spaceObserver: SpaceObserver) {
        _viewModel = StateObject(wrappedValue: ListViewModel(spaceObserver: spaceObserver))
        self.spaceObserver = spaceObserver
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.spaces, id: \.spaceID) { space in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("S\(space.spaceNumber)")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(space.isCurrentSpace ? .blue : .secondary)

                            Spacer()

                            if space.isFullScreen {
                                Text("Fullscreen")
                                    .foregroundColor(.secondary)
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
                                            .padding(.leading, 4)
                                    }
                                    Text(window.title)
                                        .lineLimit(1)
                                        .font(.system(size: 14))
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
        }
        .background(.ultraThinMaterial)
        .frame(minWidth: 300, minHeight: 400)
        .cornerRadius(10)
    }
}

#Preview {
    ListView(spaceObserver: SpaceObserver())
} 
