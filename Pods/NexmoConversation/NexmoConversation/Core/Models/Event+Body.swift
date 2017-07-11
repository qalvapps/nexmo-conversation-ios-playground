//
//  Body+Text.swift
//  NexmoConversation
//
//  Created by shams ahmed on 22/06/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Gloss

/// Body models
internal extension Event.Body {
    
    // MARK:
    // MARK: Text
    
    /// Text model
    internal struct Text: Decodable {
        
        /// Text
        internal let text: String
        
        // MARK:
        // MARK: Initializers

        internal init?(json: JSON) {
            guard let text: String = "text" <~~ json else { return nil }
            
            self.text = text
        }
    }
    
    // MARK:
    // MARK: Image
    
    /// Image - To be implemented
    internal struct Image: Decodable {
        
        // MARK:
        // MARK: Initializers

        // Unimplemented method
        internal init?(json: JSON) {
            // Unimplemented method
            return nil
        }
    }
    
    // MARK:
    // MARK: Delete
    
    /// Delete model
    internal struct Delete: Decodable {
        
        /// Event Id
        let event: String
        
        // MARK:
        // MARK: Initializers
        
        internal init?(json: JSON) {
            guard let id: String = "event_id" <~~ json else { return nil }
            
            event = id
        }
    }
}
