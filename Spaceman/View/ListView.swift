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
                    ForEach(1...3, id: \.self) { index in
                        Text("Item \(index)")
                            .padding(.leading)
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
    }
}

#Preview {
    ListView(spaceObserver: SpaceObserver())
} 