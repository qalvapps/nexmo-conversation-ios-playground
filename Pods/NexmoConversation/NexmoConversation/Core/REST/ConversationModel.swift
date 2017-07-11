//
//  ConversationModel.swift
//  NexmoConversation
//
//  Created by James Green on 30/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Gloss

/// Conversation model
@objc(NXMConversationModel)
public class ConversationModel: ConversationLiteModel {
    
    // MARK:
    // MARK: Properties
    
    /// List of members
    public internal(set) var members: [MemberModel] = []
    
    /// Date of conversation been created
    public internal(set) var created: Date?
    
    /// Display name
    public internal(set) var displayName: String?
    
    // MARK:
    // MARK: Initializers

    internal init(uuid: String, name: String="", sequenceNumber: Int=0, members: [MemberModel]=[], created: Date?, displayName: String?, state: MemberModel.State?, memberId: String?) {
        self.members.append(contentsOf: members)
        self.created = created
        self.displayName = displayName
        
        super.init(uuid: uuid, name: name, sequenceNumber: sequenceNumber, state: state, memberId: memberId)
    }
    
    internal init(lite: ConversationLiteModel) {
        super.init(copy: lite)
    }
    
    public required init?(json: JSON) {
        super.init(json: json)
        
        guard let members: [MemberModel] = "members" <~~ json else { return nil }
        self.members = members
        
        guard let formatter = DateFormatter.ISO8601 else { return nil }
        guard let date = Decoder.decode(dateForKey: "timestamp.created", dateFormatter: formatter)(json) else { return nil }
        self.created = date
        
        self.displayName = "display_name" <~~ json
    }
}

/// Compare conversation model
public func ==(lhs: ConversationModel, rhs: ConversationModel) -> Bool {
    return lhs.uuid == rhs.uuid
}
