import Foundation
import SwiftUI

class ListViewModel: ObservableObject {
    @Published var spaces: [Space] = []
    @Published var randomNumbers: [Int] = []
    private var spaceObserver: SpaceObserver
    
    init(spaceObserver: SpaceObserver) {
        self.spaceObserver = spaceObserver
        self.spaceObserver.addDelegate(self)
    }
    
    deinit {
        spaceObserver.removeDelegate(self)
    }
}

extension ListViewModel: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
        DispatchQueue.main.async {
            self.spaces = spaces
        }
    }
} 
