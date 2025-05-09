import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    
    init(spaceObserver: SpaceObserver) {
        _viewModel = StateObject(wrappedValue: ListViewModel(spaceObserver: spaceObserver))
    }
    
    var body: some View {
        List(viewModel.spaces, id: \.spaceID) { space in
            DisclosureGroup(
                isExpanded: .constant(true),
                content: {
                    if space.windows.isEmpty {
                        Text("No windows")
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    } else {
                        ForEach(space.windows, id: \.title) { window in
                            HStack {
                                if let icon = window.appIcon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                VStack(alignment: .leading) {
                                    Text(window.title)
                                        .lineLimit(1)
                                    Text(window.appName)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                Spacer()
                            }
                            .padding(.leading)
                        }
                    }
                },
                label: {
                    HStack {
                        Text("Space \(space.spaceNumber)")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(space.isCurrentSpace ? .blue : .primary)
                        
                        Spacer()
                        
                        if space.isFullScreen {
                            Text("Fullscreen")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            )
        }
        .frame(minWidth: 300, minHeight: 400)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

#Preview {
    ListView(spaceObserver: SpaceObserver())
} 