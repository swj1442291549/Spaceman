import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    
    init(spaceObserver: SpaceObserver) {
        _viewModel = StateObject(wrappedValue: ListViewModel(spaceObserver: spaceObserver))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Space \(viewModel.currentSpaceNumber)")
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
            
            List(viewModel.randomNumbers, id: \.self) { number in
                HStack {
                    Text("\(number)")
                        .font(.system(.body, design: .monospaced))
                    
                    Spacer()
                    
                    Text("Space \(viewModel.currentSpaceNumber)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}

#Preview {
    ListView(spaceObserver: SpaceObserver())
} 