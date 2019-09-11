


import Foundation
import GoogleAPIClientForREST
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
    
    weak var viewController:UIViewController?
    class func signIn(from vc: UIViewController?) {
        
        let handler = self.sharedInstance
        handler.viewController = vc
        
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
        guard let signIn = GIDSignIn.sharedInstance() else {
            print("Unable to create sign in instance")
            return
        }
        
        if signIn.clientID == nil {
            signIn.clientID = clientIDFromPlist
        }
        
        signIn.delegate = self
        
        let currentScopes = GIDSignIn.sharedInstance().scopes
        let newScopes = (currentScopes ?? []) + [kGTLRAuthScopeDriveReadonly]
        signIn.scopes = newScopes
        
        signIn.restorePreviousSignIn()
    }
    
    
    /// Either add GoogleService-Info.plist to your project
    /// or manually initialise Google Signin by calling
    /// GIDSignIn.sharedInstance().clientID = "YOUR_CLIENT_ID" in your AppDelegate
    var clientIDFromPlist:String {
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
        
        if error == nil {
            authoriser = user?.authentication.fetcherAuthorizer()
            NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInChangedNotification, object: self)
        } else {
            authoriser = nil
            NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInFailedNotification, object: self)

            //silent signin generates this error
            if let code = (error as NSError?)?.code {
                if code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                    return
                }
            }
 
            if let viewController = viewController {
                let alert = UIAlertController.init(title: "Unable to sign in to Drive",
                                                   message: error?.localizedDescription,
                                                   preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .default))
                viewController.present(alert, animated: true)
            }
        }
    }
    
    public func sign(_ signIn: GIDSignIn?, didDisconnectWith user: GIDGoogleUser?, withError error: Error?) {
        print("User disconnected")
        authoriser = nil
        NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInChangedNotification, object: self)
    }
}
