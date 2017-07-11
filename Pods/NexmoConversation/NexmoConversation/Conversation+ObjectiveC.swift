//
//  Conversation+ObjectiveC.swift
//  NexmoConversation
//
//  Created by paul calver on 28/06/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Conversation - Objective-C compatibility support
public extension Conversation {
    
    // MARK:
    // MARK: Leave - (Objective-C compatibility support)
    
    /// Leave current conversation
    ///
    /// - Parameters:
    ///   - onSuccess: method called upon completion of member leaving the conversation
    ///   - onFailure: method called upon failing to leave conversation
    @objc
    public func leave(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        leave().subscribe(
            onSuccess: onSuccess,
            onError: onFailure
        ).addDisposableTo(disposeBag)
    }
}
