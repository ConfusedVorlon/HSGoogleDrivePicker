


import Foundation
import GoogleAPIClientForREST
import GoogleSignIn


open class HSGIDSignInHandler: NSObject {
    
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
    

    class func signIn(from vc: UIViewController) {
        
        //in iOS 8, the sign-in is called with view_did_appear before the signIn_didSignIn is fired on a queue
        DispatchQueue.main.async() {
            
            guard let signIn = validSignInInstance() else {
                return
            }
            
            
            //NB - if you get a crash here, this probably indicates problems with your GoogleService-Info.plist not having the correct permissions
            //
            
            let configuration = GIDConfiguration(clientID: clientIDFromPlist)
            signIn.signIn(with: configuration,
                          presenting: vc,
                          hint: "This is a hint",
                          additionalScopes: [kGTLRAuthScopeDriveReadonly]) { user, error in
               
                if error == nil {
                    sharedInstance.authoriser = user?.authentication.fetcherAuthorizer()
                    NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInChangedNotification, object: self)
                } else {
                    sharedInstance.authoriser = nil
                    NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInFailedNotification, object: self)

                    //silent signin generates this error
//                    if let code = (error as NSError?)?.code {
//                        if code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
//                            return
//                        }
//                    }
        

                    let alert = UIAlertController.init(title: "Unable to sign in to Drive",
                                                       message: error?.localizedDescription,
                                                       preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .default))
                    vc.present(alert, animated: true)
                    
                }
            }

            
        }
        
    }
    
    class func signOut() {
        guard let signIn = validSignInInstance() else {
            return
        }
        
        signIn.disconnect { error in
            print("User disconnected")
            sharedInstance.authoriser = nil
            NotificationCenter.default.post(name: HSGIDSignInHandler.hsGIDSignInChangedNotification, object: self)
        }
        
        signIn.signOut()
    }
    
    private class func validSignInInstance() -> GIDSignIn? {
        let signIn = GIDSignIn.sharedInstance


        return signIn
    }
    
    private var authoriser: GTMFetcherAuthorizationProtocol?
    private override init() {
        super.init()
        guard let signIn = HSGIDSignInHandler.validSignInInstance() else {
            return
        }
        
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
    


}
