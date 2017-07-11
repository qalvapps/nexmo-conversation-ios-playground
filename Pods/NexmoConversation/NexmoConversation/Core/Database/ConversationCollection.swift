//
//  ConversationCollection.swift
//  NexmoConversation
//
//  Created by shams ahmed on 29/03/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Collection of conversations
public class ConversationCollection: NexmoConversation.LazyCollection<Conversation> {

    /// Database manager
    private let databaseManager: DatabaseManager
    
    // MARK:
    // MARK: Initializers
    
    /// Construct a collection of all (complete) conversations, sorted by date of most recent activity.
    internal init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        
        super.init()
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        refetch()
    }
    
    // MARK:
    // MARK: Database
    
    internal func refetch() {
        let newUuids = databaseManager.conversation.dataIncompleteConversations.map { $0.rest.uuid }
        
        uuids.removeAll(keepingCapacity: true)
        uuids.append(contentsOf: newUuids)
    }
    
    // MARK:
    // MARK: Subscript
    
    /// Get conversation with uuid
    ///
    /// - Parameter uuid: conversation uuid
    public override subscript(uuid: String) -> Conversation? {
        return ConversationClient.instance.objectCache.conversationCache.get(uuid: uuid)
    }
    
    /// Get conversation from position i
    ///
    /// - Parameter i: index
    public override subscript(i: Int) -> Conversation {
        return ConversationClient.instance.objectCache.conversationCache.get(uuid: uuids[i])!
    }
}
