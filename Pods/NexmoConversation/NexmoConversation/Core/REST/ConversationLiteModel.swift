//
//  ConversationLiteModel.swift
//  NexmoConversation
//
//  Created by James Green on 26/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Gloss

/// Conversation lite model
@objc(NXMConversationLiteModel)
public class ConversationLiteModel: NSObject, Decodable {
    
    // MARK:
    // MARK: Properties
    
    /// Conversation Id
    public let uuid: String
    
    /// Conversation name
    public let name: String
    
    /// Sequence number
    public let sequenceNumber: Int
    
    /// Member
    // TOOD: check this member is the current user as the logic is to only pick up the first member if the list
    public let member: MemberModel?
    
    // MARK:
    // MARK: Initializers

    internal init(uuid: String, name: String="", sequenceNumber: Int=0, state: MemberModel.State?, memberId: String?) {
        self.uuid = uuid
        self.name = name
        self.sequenceNumber = sequenceNumber
        
        if let memberId = memberId, let state = state {
            self.member = MemberModel(memberId, name: "", state: state, userId: "")
        } else {
            self.member = nil
        }
    }

    internal init(copy model: ConversationLiteModel) {
        uuid = model.uuid
        name = model.name
        sequenceNumber = model.sequenceNumber
        member = model.member
    }
    
    public required init?(json: JSON) {
        if let uuid: String = "id" <~~ json {
           self.uuid = uuid
        } else if let uuid: String = "uuid" <~~ json {
            self.uuid = uuid
        } else if let uuid: String = "cid" <~~ json {
            self.uuid = uuid
        } else if let uuid: String = "cname" <~~ json {
            self.uuid = uuid
        } else {
            return nil
        }

        guard let name: String = "name" <~~ json else { return nil }
        
        self.name = name

        if let sequenceNumber: Int = "sequence_number" <~~ json {
            self.sequenceNumber = sequenceNumber
        } else {
            self.sequenceNumber = 0
        }
        
        if let members: [[String: Any]] = "members" <~~ json,
            let member = members.first,
            let state: String = "state" <~~ member,
            let memberState = MemberModel.State(rawValue: state.lowercased()),
            let id: String = "member_id" <~~ member,
            let name: String = "name" <~~ member {
            self.member = MemberModel(id, name: name, state: memberState, userId: "")
        } else if let state: String = "state" <~~ json,
            let memberState = MemberModel.State(rawValue: state.lowercased()),
            let id: String = "member_id" <~~ json {
            self.member = MemberModel(id, name: "", state: memberState, userId: "")
        } else {
            self.member = nil
        }
    }
}

/// compare conversation lite model
public func ==(lhs: ConversationLiteModel, rhs: ConversationLiteModel) -> Bool {
    return lhs.uuid == rhs.uuid
}
