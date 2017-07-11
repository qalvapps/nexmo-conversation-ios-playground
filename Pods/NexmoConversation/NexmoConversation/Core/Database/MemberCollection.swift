//
//  MemberCollection.swift
//  NexmoConversation
//
//  Created by shams ahmed on 29/03/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

public class MemberCollection: NexmoConversation.LazyCollection<Member> {
    
    private let databaseManager: DatabaseManager?
    
    // MARK:
    // MARK: Initializers
    
    /// Construct a collection of all members in the given conversation.
    internal init(conversationUuid: String, databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        
        super.init()
        
        setup(conversationUuid)
    }
    
    /// Constrict a collection of all member to whom an event was distributed.
    internal init(event: TextEvent) {
        databaseManager = nil
        
        super.init()
        
        setup(event)
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup(_ conversationUuid: String) {
        if let memberIds = self.databaseManager?.member[parent: conversationUuid].map({ member in member.rest.id }) {
            uuids.append(contentsOf: memberIds)
        }
    }
    
    private func setup(_ event: TextEvent) {
        uuids = event.data.distribution
    }
    
    // MARK:
    // MARK: Subscript
    
    /// Get member by Member Id
    ///
    /// - Parameter uuid: Member iD
    public override subscript(uuid: String) -> Member? {
        return ConversationClient.instance.objectCache.memberCache.get(uuid: uuid) // TODO Test this actually works
    }
    
    /// Get member from position i
    ///
    /// - Parameter i: i
    public override subscript(i: Int) -> Member {
        return ConversationClient.instance.objectCache.memberCache.get(uuid: uuids[i])!
    }
    
    // MARK:
    // MARK: Cache
    
    /* Get a list of all users. */
    public var allUsers: [User] {
        /* Mutex. */
        mutex.lock()
        defer { mutex.unlock() }
        
        if _userMembershipLookup == nil {
            populateLookup()
        }
        
        return _userMembershipLookup?.map { $0.key } ?? []
    }
    
    /* Get the membership of a given user. */
    private var _userMembershipLookup: [User: [Member]]?
    
    private func populateLookup() {
        _userMembershipLookup = [:]
        
        /* Produce a dictionary of membership lists indexed by user. */
        for member in (self as NexmoConversation.LazyCollection<Member>) {
            var membership = _userMembershipLookup?[member.user] ?? []
            
            membership.append(member)
            _userMembershipLookup?[member.user] = membership
        }
    }
    
    // MARK:
    // MARK: Helper
    
    public func membershipForUser(user: User) -> [Member] {
        /* Mutex. */
        mutex.lock()
        defer { mutex.unlock() }
        
        if _userMembershipLookup == nil {
            populateLookup()
        }
        
        guard let result = _userMembershipLookup?[user] else {
            // rare crashes when using subscript where the user equal (==) does not match a user. could be swift 3 issue but can't find a specfic ticket on swift bug list
            return _userMembershipLookup?.filter { $0.key == user }.first?.value ?? []
        }
        
        return result
    }
}
