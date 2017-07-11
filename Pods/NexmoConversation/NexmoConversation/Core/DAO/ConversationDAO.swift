//
//  ConversationDAO.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 31/03/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Conversation data access object
internal struct ConversationDAO: CRUD {
    
    typealias T = DBConversation
    
    internal var database: Database

    /// Fetch conversation which require a sync
    internal var dirtyConversations: [T] {
        return database.queue.inDatabase { T.all().filter(sql: "requiresSync = 1").fetchAll($0) }
    }
    
    /// Fetch conversation which require a sync
    internal var dataIncompleteConversations: [T] {
        return database.queue.inDatabase {
            T.all()
            .filter(sql: "dataIncomplete = 0")
            .order(sql: "lastUpdated DESC")
            .fetchAll($0)
        }
    }
    
    /// Fetch all conversations
    ///
    /// - Returns: conversation lists
    internal var all: [T] { return database.queue.inDatabase { T.fetchAll($0) } }
    
    // MARK:
    // MARK: Subscript
    
    /// fetch conversation
    ///
    /// - Parameter uuid: conversation uuid
    internal subscript(_ uuid: String) -> T? { return self.database.queue.inDatabase { T.fetchOne($0, key: uuid) } }
    
    // MARK:
    // MARK: Create

    /// Create table of type T
    ///
    /// - Returns: success/fail
    /// - Throws: CRUDErrors
    internal func createTable(in database: Database.Provider) throws {
        try database.execute("CREATE TABLE conversations (" +
            "uuid TEXT NOT NULL PRIMARY KEY, " +
            "name TEXT NOT NULL, " +
            "displayName TEXT, " +
            "sequenceNumber INTEGER NOT NULL, " +
            "timestampCreated DATETIME, " +
            "requiresSync BOOLEAN NOT NULL, " +
            "dataIncomplete BOOLEAN NOT NULL, " +
            "mostRecentEventIndex INTEGER, " +
            "lastUpdated DATETIME NOT NULL, " +
            "memberId TEXT NULL, " +
            "state INTEGER NULL" +
            ")"
        )
    }

    // MARK:
    // MARK: Delete
    
    /// Delete all item of type T
    ///
    /// - Parameter item: item to be deleted
    /// - Returns: success/fail
    /// - Throws: CRUDErrors
    internal func deleteAll() throws {
        _ = try database.queue.inDatabase { try T.deleteAll($0) }
    }
}
