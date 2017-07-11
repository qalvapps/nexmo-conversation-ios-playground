//
//  DBMember.swift
//  NexmoConversation
//
//  Created by James Green on 30/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import GRDB

internal class DBMember: Record {
    
    /* Data fields / columns. */
    internal var parent: String /* conversation uuid */
    
    internal var rest: MemberModel // Just use the REST definition directly because no point in duplicating all the fields twice.
    
    // MARK:
    // MARK: Initializers
    
    init (conversationUuid: String, member: MemberModel) {
        rest = member
        parent = conversationUuid
        
        super.init()
    }
    
    /* GRDB */
    required init(row: Row) {
        parent = row.value(named: "parent")
        
        let memberId: String = row.value(named: "memberId")
        let name: String = row.value(named: "name")
        let stateInt: Int32 = row.value(named: "state")
        let state = MemberModel.State.from(stateInt)!
        let userId: String = row.value(named: "userId")

        rest = MemberModel(memberId, name: name, state: state, userId: userId)
        
        super.init(row: row)
    }
    
    // MARK:
    // MARK: Database
    
    override class var databaseTableName: String {
        return "members"
    }
    
    override var persistentDictionary: [String : DatabaseValueConvertible?] {
        return ["parent": parent,
                "memberId": rest.id,
                "name": rest.name,
                "state": rest.state.intValue,
                "userId": rest.userId
        ]
    }
}
