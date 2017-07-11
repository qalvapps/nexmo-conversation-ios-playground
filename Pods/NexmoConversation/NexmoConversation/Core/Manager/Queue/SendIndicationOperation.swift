//
//  SendIndicationOperation.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/05/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Operation to send a indctator
internal struct SendIndicationOperation: Operation {
    
    internal typealias T = Void
    
    internal enum Errors: Error {
        case eventNotFound
        case failedToProcessEvent
    }
    
    private let task: DBTask
    private let cache: CacheManager
    private let database: DatabaseManager
    private let eventController: EventController
    
    // MARK:
    // MARK: Initializers
    
    internal init(_ task: DBTask,
                  cache: CacheManager,
                  database: DatabaseManager,
                  eventController: EventController) {
        self.task = task
        self.cache = cache
        self.database = database
        self.eventController = eventController
    }
    
    // MARK:
    // MARK: Operation
    
    internal func perform() throws -> Maybe<T> {
        return try send(task)
    }
    
    // MARK:
    // MARK: Private - Send indicate

    private func send(_ task: DBTask) throws -> Maybe<T> {
        task.beingProcessed = true
        try database.task.insert(task)
        
        guard let messageUuid = task.related,
            let message = cache.eventCache.get(uuid: messageUuid) as? TextEvent,
            let memberId = message.conversation.ourMemberRecord?.uuid else {
            throw Errors.eventNotFound
        }
        
        var type: Event.EventType = .textDelivered
        
        if task.type == .indicateDelivered {
            if message is ImageEvent {
                type = .imageDelivered
            } else {
                type = .textDelivered
            }
        } else if task.type == .indicateSeen {
            if message is ImageEvent {
                type = .textSeen
            } else {
                type = .textSeen
            }
        }
        
        let sendEvent = SendEvent(conversationId: message.conversation.uuid, from: memberId, type: type, eventId: Int(message.data.id))
        
        return eventController.send(sendEvent).map { _ -> T in
            _ = try? self.database.task.delete(task)
            
            return ()
        }.asMaybe()
    }
}
