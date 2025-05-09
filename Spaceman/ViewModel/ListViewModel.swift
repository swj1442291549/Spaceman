import Foundation
import SwiftUI

class ListViewModel: ObservableObject {
    @Published var currentSpaceNumber: Int = 1
    @Published var randomNumbers: [Int] = []
    private var spaceObserver: SpaceObserver
    
    init(spaceObserver: SpaceObserver) {
        self.spaceObserver = spaceObserver
        self.spaceObserver.delegate = self
        generateRandomNumbers()
    }
    
    func generateRandomNumbers() {
        randomNumbers = (1...10).map { _ in Int.random(in: 1...100) }
    }
}

extension ListViewModel: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
        if let currentSpace = spaces.first(where: { $0.isCurrentSpace }) {
            DispatchQueue.main.async {
                self.currentSpaceNumber = currentSpace.spaceNumber
                self.generateRandomNumbers() // Generate new numbers when space changes
            }
        }
    }
} 