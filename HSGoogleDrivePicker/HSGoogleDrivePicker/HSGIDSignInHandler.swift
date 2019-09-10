


import Foundation
import GoogleAPIClient
import GoogleSignIn

open class HSGIDSignInHandler: NSObject, GIDSignInDelegate {
    static let hsGIDSignInChangedNotification = NSNotification.Name("HSGIDSignInChangedNotification")
    static let hsGIDSignInFailedNotification = NSNotification.Name("HSGIDSignInFailedNotification")
    
    static let sharedInstance = HSGIDSignInHandler()
    
    
    class var authoriser:GTMFetcherAuthorizationProtocol? {
        return HSGIDSignInHandler.sharedInstance.authoriser
    }
    
    class func canAuthorise() -> Bool {
        if HSGIDSignInHandler.sharedInstance.authoriser?.canAuthorize == true {
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
    
    var authoriser: GTMFetcherAuthorizationProtocol?
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().clientID = clientID
        GIDSignIn.sharedInstance().delegate = self
        
        let currentScopes = GIDSignIn.sharedInstance().scopes
        GIDSignIn.sharedInstance().scopes = currentScopes ?? [] + [kGTLAuthScopeDrive]
    }
    
    var clientID:String {
        let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path ?? "") as? [String:Any]? {
            let clientID = dict?["CLIENT_ID"] as? String
            if let clientID = clientID  {
                return clientID
            }
        }
        
        fatalError("GoogleService-Info.plist hasn't been added to the project")
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
