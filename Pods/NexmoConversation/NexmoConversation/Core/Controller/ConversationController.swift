//
//  ConversationController.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/11/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Conversation controller to handle fetching conversation request, fetching save to cache and database
@objc(NXMConversationController)
public class ConversationController: NSObject {
    
    // MARK:
    // MARK: Properties
    
    /// Network controller
    private let networkController: NetworkController
    
    /// Rx
    internal let disposeBag = DisposeBag()

    /// Sync Manager
    internal weak var syncManager: SyncManager?

    /// Account controller
    private let account: AccountController

    /// Contains a collection of all conversations.
    public let conversations: ConversationCollection
    
    // MARK:
    // MARK: Properties - Observable
    
    // TODO: refactor conversationAdded for Rx
    
    /**
     
     Signal for when a conversation is added.
     
     Can add handlers to respond to adding a conversation if required, to refresh a conversation list for example.
     
     Using selectors:
     
     ```
     conversationAdded.addHandler(self, selector: #selector(MyClass.handleAddedConversation))
     ```
     
     Using swift handlers:
     
     ```
     conversationAdded.addHandler(self, handler: MyClass.handleAddedConversation)
     ```
     
     Handler should have Conversation as a parameter:
     
     ```
     func handleAddedConversation(conversationAdded: Conversation) {
     
     // Refresh conversation list
     
     }
     ```
     */
    public let conversationAdded = Signal<Conversation>()
    
    // TODO: refactor conversationLeft for Rx
    
    /**
     
     Signal for when a conversation is left.
     
     Can add handlers to respond to leaving a conversation if required, to refresh a conversation list for example.
     
     Using selectors:
     
     ```
     conversationLeft.addHandler(self, selector: #selector(MyClass.handleLeftConversation))
     ```
     
     Using swift handlers:
     
     ```
     conversationLeft.addHandler(self, handler: MyClass.handleLeftConversation)
     ```
     
     Handler should have Conversation as a parameter:
     
     ```
     func handleLeftConversation(conversationLeft: Conversation) {
     
     // Refresh conversation list
     
     }
     ```
     */
    public let conversationLeft = Signal<Conversation>()
    
    // MARK:
    // MARK: Initializers
    
    internal init(network: NetworkController, databaseManager: DatabaseManager, account: AccountController) {
        networkController = network
        conversations = ConversationCollection(databaseManager: databaseManager)
        self.account = account
    }
    
    // MARK:
    // MARK: Create
    
    /// Create a new conversation and join with user id
    ///
    /// - Parameters:
    ///   - model: conversation parameter
    ///   - join: should join the new conversation
    /// - Returns: observable with status result
    public func new(_ model: ConversationController.CreateConversation, withJoin shouldJoin: Bool = false) -> Observable<Conversation> {
        var uuid: String?

        guard shouldJoin else { return new(model) }

        guard let userId = account.userId else {
            return Observable<Conversation>.error(ConversationClient.Errors.userNotInCorrectState)
        }
        
        return Observable<String>.create { observer -> Disposable in
            self.networkController.conversationService.create(with: model, success: { newUuid in
                uuid = newUuid

                observer.onNextWithCompleted(newUuid)
            }, failure: { error in
                observer.onError(error)
            })

            return Disposables.create()
        }
        .flatMap { self.join(JoinConversation(userId: userId), forUUID:$0) }
        .map { _ in uuid }
        .unwrap()
        .delay(1.0, scheduler: MainScheduler.asyncInstance) // TODO: remove delay once backend fixes indexing issue [June 17]
        .flatMap { self.conversation(with: $0) }
        .observeOnBackground()
    }
    
    /// Create a new conversation
    ///
    /// - Parameter model: model for new conversation
    /// - Returns: Conversation
    internal func new(_ model: ConversationController.CreateConversation) -> Observable<Conversation> {
        return Observable<String>.create { observer -> Disposable in
            self.networkController.conversationService.create(with: model, success: { uuid in
                observer.onNextWithCompleted(uuid)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
            }
            .flatMap { self.conversation(with: $0) }
            .observeOnBackground()
    }

    // MARK:
    // MARK: Fetch
    
    /// Fetch all users conversations
    ///
    /// - Parameter userId: user id
    /// - Returns: observable with lite conversations
    public func all(with userId: String) -> Observable<[ConversationLiteModel]> {
        return Observable<[ConversationLiteModel]>.create { observer in
            self.networkController.conversationService.all(for: userId, success: { conversations in
                observer.onNextWithCompleted(conversations)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
            }
            .observeOnBackground()
    }
    
    /// Fetch all conversations
    ///
    /// - Returns: observable with lite conversations
    public func all() -> Observable<[ConversationLiteModel]> {
        return Observable<[ConversationLiteModel]>.create { observer in
            self.networkController.conversationService.all(success: { conversations in
                observer.onNextWithCompleted(conversations)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
            }
            .observeOnBackground()
    }

    // MARK:
    // MARK: Detailed Conversation

    /// Fetch a detailed conversation
    ///
    /// - Parameter conversationId: conversation Id
    /// - Returns: observable with conversation
    public func conversation(with conversationId: String) -> Observable<Conversation> {
        return Observable<ConversationModel>.create { observer in
            self.networkController.conversationService.conversation(with: conversationId, success: { conversation in
                observer.onNextWithCompleted(conversation)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
            }
            // TODO: refactor: get DAO to update/insert new conversation and the get Sync to do its work
            // i.e .map { try self.dao.insert($0) }
//            .retry(3)
            .map { try self.syncManager?.save($0) }
            .unwrap()
            .observeOnBackground()
    }

    // MARK:
    // MARK: Internal - Join

    /// Join a conversation
    ///
    /// - Parameters:
    ///   - model: join parameter
    ///   - uuid: conversation uuid
    /// - Returns: observable with status result
    internal func join(_ model: JoinConversation, forUUID uuid: String) -> Observable<MemberModel.State> {
        return Observable<MemberModel.State>.create { observer -> Disposable in
            self.networkController.conversationService.join(with: model, forUUID: uuid, success: { status in
                observer.onNextWithCompleted(status.state)
            }, failure: { error in
                observer.onError(error)
            })

            return Disposables.create()
            }
            .observeOnBackground()
    }
}
