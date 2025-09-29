import FoundationModels
import Network
import SwiftUI

public enum FetchState {
    case empty
    case loading
    case loaded
    case error
}

@Observable
@MainActor
public final class Inventory {
    public var expiryPercentage: Int
    
    public var state: FetchState = .empty
    
    let api = KeepFreshAPI()
    let model = SystemLanguageModel.default
    
    public init() {}
    
    public func generateExpiryPercentage() async {
        state = .loading
        
        do {
            let session = LanguageModelSession(instructions: """
            You are an expert in predicting food wastage. For each set of data, calculate and return only the most likely waste percentage for the user's next purchase of a given food item.
                Consumed - means 0% food waste for a given food waste
            """)
            let response = try await session.respond(to: """
            Food Name: Chicken Thighs
            Purchased Count: 8
            Consumed Count: 4
            Discard Count: 4
            Average percentage wasted of product when discarded: 25%
            """)
            
        } catch {
            state = .error
            return
        }
        
        state = .loaded
    }
}
