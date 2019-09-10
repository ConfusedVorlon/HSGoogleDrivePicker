


import Foundation
import GoogleAPIClient
import GoogleSignIn

open class HSGIDSignInHandler: NSObject, GIDSignInDelegate {
    static let hsGIDSignInChangedNotification = NSNotification.Name("HSGIDSignInChangedNotification")
    static let hsGIDSignInFailedNotification = NSNotification.Name("HSGIDSignInFailedNotification")
    
    static let sharedInstance = HSGIDSignInHandler()
    
    
    class func authoriser() -> GTMFetcherAuthorizationProtocol? {
        return HSGIDSignInHandler.sharedInstance.authoriser
    }
    
    class func canAuthorise() -> Bool {
        if HSGIDSignInHandler.sharedInstance.authoriser?.canAuthorize != nil {
            return true
        }
        
        return false
    }
    
    class func signIn(from vc: UIViewController?) {
        
        _ = self.sharedInstance
        
        //in iOS 8, the sign-in is called with view_did_appear before the signIn_didSignIn is fired on a queue
        DispatchQueue.main.async(execute: {
            
            if let vc = vc {
                GIDSignIn.sharedInstance().presentingViewController = vc
            }
            GIDSignIn.sharedInstance().signIn()
        })
        
    }
    
    class func signOut() {
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
    }
    
    weak var authoriser: GTMFetcherAuthorizationProtocol?
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().clientID = "544696410407-pqo2mh8os7dl2er7e9ts1bg30epf6n2p.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        let currentScopes = GIDSignIn.sharedInstance().scopes
        GIDSignIn.sharedInstance().scopes = currentScopes ?? [] + [kGTLAuthScopeDrive]
    }
    
    public func sign(_ signIn: GIDSignIn?, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        authoriser = user?.authentication.fetcherAuthorizer()
        
        if error == nil {
            NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInChangedNotification, object: self)
        } else {
            NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInFailedNotification, object: self)
            
            let av = UIAlertView(title: "Unable to sign in to Drive",
                                 message: error?.localizedDescription ?? "",
                                 delegate: nil,
                                 cancelButtonTitle: "OK",
                                 otherButtonTitles: "")
            av.show()
        }
    }
    
    public func sign(_ signIn: GIDSignIn?, didDisconnectWith user: GIDGoogleUser?, withError error: Error?) {
        print("User disconnected")
        authoriser = nil
        NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInChangedNotification, object: self)
    }
}
