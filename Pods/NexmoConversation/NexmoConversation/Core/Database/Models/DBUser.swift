//
//  DBUser.swift
//  NexmoConversation
//
//  Created by James Green on 01/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import GRDB

internal class DBUser: Record {
    /* Data fields / columns. */
    internal var rest: UserModel // Just use the REST definition directly because no point in duplicating all the fields twice.

    init (data: UserModel) {
        rest = data
        super.init()
    }
    
    internal init(name: String) { // TODO This is currently used to fake a user. It can be removed once the server API allows querying of users.
        self.rest = UserModel(displayName: name, imageUrl: name, uuid: name, name: name)
        super.init()
    }
    
    /* GRDB */
    required init(row: Row) {
        let displayName: String = row.value(named: "displayName")
        let imageUrl: String = row.value(named: "imageUrl")
        let uuid: String = row.value(named: "uuid")
        let name: String = row.value(named: "name")
        
        rest = UserModel(displayName: displayName, imageUrl: imageUrl, uuid: uuid, name: name)
        
        super.init(row: row)
    }
    
    override class var databaseTableName: String {
        return "users"
    }
    
    override var persistentDictionary: [String : DatabaseValueConvertible?] {
        return ["displayName": rest.displayName,
                "imageUrl": rest.imageUrl,
                "name": rest.name,
                "uuid": rest.uuid
        ]
    }
}
