import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    
    init(spaceObserver: SpaceObserver) {
        _viewModel = StateObject(wrappedValue: ListViewModel(spaceObserver: spaceObserver))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Spaces")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    viewModel.generateRandomNumbers()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            List(viewModel.spaces, id: \.spaceID) { space in
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
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}

#Preview {
    ListView(spaceObserver: SpaceObserver())
} 