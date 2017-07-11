//
//  MemberModel.swift
//  NexmoConversation
//
//  Created by James Green on 30/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Gloss

// TODO: a model should not be mutable remove all var on this class, other classes need to recreate a struct object to avoid any weird issue
public struct MemberModel: Decodable {
    
    // MARK:
    // MARK: Enum

    /// Member State
    ///
    /// - joined: Member is joined to this conversation
    /// - invited: Member has been invited to this conversation
    /// - left: Member has left this conversation
    /// - knocking: Member would like to join this conversation
    public enum State: String {
        case joined
        case invited
        case left
        case knocking
        
        // MARK:
        // MARK: Helper
        
        internal var intValue: Int32 {
            switch self {
            case .joined: return 0
            case .invited: return 1
            case .left: return 2
            case .knocking: return 3
            }
        }
        
        internal static func from(_ int32: Int32) -> State? {
            switch int32 {
            case 0: return .joined
            case 1: return .invited
            case 2: return .left
            case 3: return .knocking
            default: return nil
            }
        }
    }
    
    /// Action a member can perform or be in a state
    ///
    /// - invite: member requested to be invited
    /// - join: member requested to join
    public enum Action: String, Equatable {
        case invite
        case join
        
        /// Compare Action
        static public func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.invite, .invite): return true
            case (.join, .join): return true
            case (.invite, _),
                 (.join, _): return false
            }
        }
    }
    
    /// Channel type member receives messages
    ///
    /// - APP: SDK
    /// - SIP: sip
    /// - PSTN: pstn
    /// - SMS: sms
    /// - OTT: ott
    public enum Channel: String, Equatable {
        case app
        case sip
        case pstn
        case sms
        case ott
        
        /// Compare Channel
        static public func == (lhs: Channel, rhs: Channel) -> Bool {
            switch (lhs, rhs) {
            case (.app, .app): return true
            case (.sip, .sip): return true
            case (.pstn, .pstn): return true
            case (.sms, .sms): return true
            case (.ott, .ott): return true
            case (.app, _),
                 (.sip, _),
                 (.pstn, _),
                 (.sms, _),
                 (.ott, _): return false
            }
        }
    }
    
    // MARK:
    // MARK: Properties
    
    /// member id
    public internal(set) var id: String
    
    /// name
    public internal(set) var name: String
    
    /// state
    public internal(set) var state: State
    
    /// user id
    public internal(set) var userId: String
    
    // MARK:
    // MARK: Initializers

    public init(_ memberId: String, name: String, state: State, userId: String) {
        self.id = memberId
        self.name = name
        self.state = state
        self.userId = userId
    }
    
    public init?(json: JSON) {
        guard let memberId: String = "member_id" <~~ json else { return nil }
        guard let name: String = "name" <~~ json else { return nil }
        guard let stateString: String = "state" <~~ json,
            let state: State = State(rawValue: stateString.lowercased()) else { return nil }
        guard let userId: String = "user_id" <~~ json else { return nil }
        
        self.id = memberId
        self.name = name
        self.state = state
        self.userId = userId
    }
    
    public init?(json: JSON, state: State) {
        guard let memberId: String = "member_id" <~~ json else { return nil }
        guard let name: String = "name" <~~ json else { return nil }
        guard let userId: String = "user_id" <~~ json else { return nil }
        
        self.id = memberId
        self.name = name
        self.state = state
        self.userId = userId
    }
}
