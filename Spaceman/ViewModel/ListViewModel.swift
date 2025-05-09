import Foundation
import SwiftUI

class ListViewModel: ObservableObject {
    @Published var spaces: [Space] = []
    @Published var randomNumbers: [Int] = []
    private var spaceObserver: SpaceObserver
    
    init(spaceObserver: SpaceObserver) {
        self.spaceObserver = spaceObserver
        self.spaceObserver.addDelegate(self)
        generateRandomNumbers()
    }
    
    deinit {
        spaceObserver.removeDelegate(self)
    }
    
    func generateRandomNumbers() {
        randomNumbers = (1...10).map { _ in Int.random(in: 1...100) }
    }
}

extension ListViewModel: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
//        print("ListViewModel received spaces: \(spaces.count)")
        DispatchQueue.main.async {
            self.spaces = spaces
//            print("ListViewModel updated spaces array: \(self.spaces.count)")
            self.generateRandomNumbers() // Generate new numbers when space changes
        }
    }
} 
