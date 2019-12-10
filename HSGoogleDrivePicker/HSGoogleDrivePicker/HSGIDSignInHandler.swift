


import Foundation
import GoogleAPIClientForREST
import GoogleSignIn


open class HSGIDSignInHandler: NSObject, GIDSignInDelegate {
    
    @objc public static let hsGIDSignInChangedNotification = NSNotification.Name("HSGIDSignInChangedNotification")
    @objc public static let hsGIDSignInFailedNotification = NSNotification.Name("HSGIDSignInFailedNotification")
    
    public static let sharedInstance = HSGIDSignInHandler()
    public class var authoriser:GTMFetcherAuthorizationProtocol? {
        return HSGIDSignInHandler.sharedInstance.authoriser
    }
    
    class func canAuthorise() -> Bool {
        if HSGIDSignInHandler.sharedInstance.authoriser?.canAuthorize == true {
            return true
        }
        
        return false
    }
    
    private weak var viewController:UIViewController?
    class func signIn(from vc: UIViewController?) {
        
        let handler = self.sharedInstance
        handler.viewController = vc
        
        //in iOS 8, the sign-in is called with view_did_appear before the signIn_didSignIn is fired on a queue
        DispatchQueue.main.async(execute: {
            
            guard let signIn = validSignInInstance() else {
                return
            }
            
            if let vc = vc {
                signIn.presentingViewController = vc
            }
            
            //NB - if you get a crash here, this probably indicates problems with your GoogleService-Info.plist not having the correct permissions
            //
            signIn.signIn()

            
        })
        
    }
    
    class func signOut() {
        guard let signIn = validSignInInstance() else {
            return
        }
        
        signIn.disconnect()
        signIn.signOut()
    }
    
    private class func validSignInInstance() -> GIDSignIn? {
        guard let signIn = GIDSignIn.sharedInstance() else {
            print("Unable to create sign in instance")
            return nil
        }
        
        if signIn.clientID == nil {
            signIn.clientID = clientIDFromPlist
        }
        
        if signIn.clientID == nil {
            print("Unable to get signIn clientID")
            return nil
        }

        return signIn
    }
    
    private var authoriser: GTMFetcherAuthorizationProtocol?
    private override init() {
        super.init()
        guard let signIn = HSGIDSignInHandler.validSignInInstance() else {
            return
        }
  
        signIn.delegate = self
        
        let currentScopes = signIn.scopes
        let newScopes = (currentScopes ?? []) + [kGTLRAuthScopeDriveReadonly]
        signIn.scopes = newScopes
        
        signIn.restorePreviousSignIn()
    }
    
    private static var clientIDFromPlist:String {
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
