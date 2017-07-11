//: Playground - noun: a place where people can play

import UIKit
import Foundation
@testable import NexmoConversation
import PlaygroundSupport

// current page requires "indefinite execution"
PlaygroundPage.current.needsIndefiniteExecution = true

// if true, will trigger endpoint calls in dev
// if false will attempt to use client sdk which is prod

let runUsingDevRest = false
// REST
let baseURL = "https://api.dev.nexmoinc.net"
let tokenURL = baseURL + "/token"
let conversationURL = baseURL + "/v1/users/%@/conversations"

let apiId: String = {
    return (runUsingDevRest) ? "0d3bc535-cc2d-41ed-8799-5a0905c7d938" : "62572a86-365a-4f96-aaee-1b51d0baa082"
}()

let user : String = {
    return (runUsingDevRest) ? "demo1@nexmo.com" : "billybob"
}()

let conversationUser : String = {
    return (runUsingDevRest) ? "USR-a2f34180-526c-49f8-b385-0d3376124bb8" : "USR-082d45c6-3b80-4604-9593-acb45612cf50"
}()

// PROD token
// token was generated using nexmo jwt:generate ./private.key sub=billybob application_id=62572a86-365a-4f96-aaee-1b51d0baa082
// but login comes back wth invalid token

let apiToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE0OTk3MDgxNDYsImp0aSI6IjM0Y2MzZjMwLTY1OTYtMTFlNy04ZDQwLTk3MDFiNWMwYThkMiIsInN1YiI6ImJpbGx5Ym9iIiwiYXBwbGljYXRpb25faWQiOiI2MjU3MmE4Ni0zNjVhLTRmOTYtYWFlZS0xYjUxZDBiYWEwODIifQ.dg2ARVIZ03JF5EclszZ7CloaqpRMQa3Y6cL4DA864yKpHnl-PCK61jyBbVbLzs07SRUuY2sx8lH9oESgVl2YyVwUZiNY6TnJ3IZHmGZa7uOBvoUufbvmjPvs2kHkSZgDNB_Nn2QEaQ914P3V3mT2unbHoOSrMsM8E9uKLVvpjotUtTiFzAcoTQWQk6Qrgu1yw6yEOkg-aa58_jemwgkoG1SSHHu-T306f-te-ZDFU1UXgGTKWDc9i4QvaXOILojHpBC9jZ-JOVcndLbtier4eS1HjJmpB3qvF5P0x-QE6_Cew69ATHzXs1MjbbW1q8K7gxJaTi-y9Y4RZk7Ip4PfUA"

// SDK
let client = ConversationClient.instance

client.networkController.socketState.asDriver().debug().asObservable().subscribe(onNext: { state in
    print(state)
}, onError: { error in
    print(error)
}, onCompleted: {
    print("completed")
}).addDisposableTo(client.disposeBag)

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

// URL session
// When using Charles, the network requests will always fail unless you can bypass ATS.
public class NetworkEnabler: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

let enabler = NetworkEnabler()

let session = URLSession(configuration: URLSession.shared.configuration, delegate: enabler, delegateQueue: nil)

// encapsulate execution completion
func completeExecution() {
    PlaygroundPage.current.finishExecution()
}

// TOKEN
// only dev has an endpoint for this
func generateToken(with endpointURL: String, apiId: String, user: String, completionHandler: @escaping (Bool, String) -> Swift.Void) {
    
    let composedUrl = String(format: "%@/%@/%@", endpointURL, apiId, user)

    print("composedUrl \(composedUrl)")
    
    // generate token and if successful, login
    guard let url = URL(string: composedUrl) else {
        completeExecution()
        return
    }
    
    let task = session.dataTask(with: url) { (data, response, error) in
        
        if let error = error {
            print("generate token error \(error)")
            completeExecution()
            return
        }
        
        let dataString = String(data: data!, encoding: .utf8)
        
        print("dataString \(dataString!)")
        
        //let json2 = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: Any]
        
        //print("json \(json2!)")
        
        guard let data = data, let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any], let token = json["token"] as? String else {
            
            print("json probs")
            completeExecution()
            return
        }
        
        completionHandler(true, token)
    }
    
    task.resume()
}

// LOGIN
func descriptionForLoginResult(_ result: ConversationClient.LoginResult) -> String {
    switch result {
    case .success: return "login success"
    case .failed: return "login failed"
    case .invalidToken: return "login invalid token"
    case .sessionInvalid: return "login sesion invalid"
    case .expiredToken: return "expired token"
    }
}

func loginWith(with token: String, completionHandler: @escaping (Bool) -> Swift.Void) {
    
    print("login with token \(token)")
    
    client.login(with: "token", { result in
        let resultDescription  = descriptionForLoginResult(result)
        print("login result \(resultDescription)")
        
        let success = (result == .success) ? true : false
        completionHandler(success)
    })
}

// CONVERSATION
// rest
func fetchConversations(with endpointURL: String, user: String, token: String) {
    
    let composedUrl = String(format: endpointURL, user)
    print("composedUrl \(composedUrl)")
    
    guard let url = URL(string: composedUrl) else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    let task = session.dataTask(with: request) {
        (
        data, response, error) in
        
        guard let data = data, let _:URLResponse = response, error == nil else {
            print("error")
            completeExecution()
            return
        }
        
        let dataString =  String(data: data, encoding: String.Encoding.utf8)
        
        print(dataString ?? "couldnt output conversation list")
    }
    
    task.resume()
}

// client
func fetchConversationsUsingClient(user: String?) {
    
    if let user = user {
        client.conversation.all(with: conversationUser, { (conversations) in
            print("all conversations fetched")
        }, onFailure: { (error) in
            print("all conversations failed \(error)")
        })
    } else {
        client.conversation.all({ (conversations) in
            print("all conversations fetched")
        }, onFailure: { (error) in
            print("all conversations failed \(error)")
        })
    }
}

func createConversation() {
    
    //    if let userId = client.account.userId {
    //      print("userId \(userId)")
    //     }
    
    client.conversation.new(with: "test1", { (conversation) in
        print("created & joined convo")
    }) { (error) in
        print("create convo failure oh : \(error)")
    }
}

// MAIN ACTIONS

if runUsingDevRest {

    generateToken(with: tokenURL, apiId: apiId, user: user, completionHandler: { (success, token) in
    
        // cant login as client runs against prod
        if success == true {
            fetchConversations(with: conversationURL, user: conversationUser, token: token)
        }
    })
} else {
    loginWith(with: apiToken, completionHandler: { (success) in
        //    if success == true {
        //        fetchConversations(with: conversationURL, user: conversationUser, token: apiToken)
        //    }
        
        fetchConversationsUsingClient(user: conversationUser)
    })
}