import GoogleSignIn
import GoogleAPIClient
import UIKit

/// Navigation controller to present the File Viewer and signin controller
open class HSDrivePicker: UINavigationController {
    /** Provide your API secret
     Note that the client ID is read from your GoogleService-Info.plist
     **/
    
    
    /** Present the picker from your view controller. It will present as a modal form.
     The completion returns both the file, and the authorised manager which can be used to download the file **/
    
    
    /*
     
     Appearance can mostly be managed through the appearance proxy.
     e.g.  [[UINavigationBar appearance] setBackgroundImage: <your image> ];
     
     or to style the segmented control (which is addmittedly wierd)
     
     //selected text
     [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateSelected];
     //not selected text
     [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor greenColor]} forState:UIControlStateNormal];
     //background
     [[UIImageView appearanceWhenContainedIn:[UISegmentedControl class],nil] setTintColor:[UIColor blueColor]];
     
     */
    
    
    //*specify status bar style. Default is UIStatusBarStyleDefault *
    
    
    /**
     Handle the url callback from google authentication
     
     @param url the callback url
     */
    
    
    private var viewer: HSDriveFileViewer?
    private var thePreferredStatusBarStyle: UIStatusBarStyle = .default
    
    public class func handle(_ url: URL?) -> Bool {
        _ = HSGIDSignInHandler.sharedInstance
        if GIDSignIn.sharedInstance().handle(url) {
            return true
        }
        
        return false
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public init() {
        let viewer = HSDriveFileViewer()

        
        super.init(rootViewController: viewer)
        modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.viewer = viewer
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return thePreferredStatusBarStyle
    }
    
    public func setPreferredStatusBarStyle(_ thePreferredStatusBarStyle: UIStatusBarStyle) {
        self.thePreferredStatusBarStyle = thePreferredStatusBarStyle
    }
    
    public func pick(from vc: UIViewController?, withCompletion completion: @escaping (_ manager: HSDriveManager?, _ file: GTLDriveFile?) -> Void) {
        viewer?.completion = completion
        viewer?.shouldSignInOnAppear = true
        
        vc?.present(self, animated: true)
        
    }
    
    func downloadFileContent(withService service: GTLServiceDrive?, file: GTLDriveFile?, completionBlock: @escaping (Data?, Error?) -> Void) {
        
        guard let downloadURL = file?.downloadURL else {
            completionBlock(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil))
            return
        }
            let fetcher = service?.fetcherService.fetcher(with: downloadURL)
            
        fetcher?.beginFetch(completionHandler: { data, error in
                if error == nil {
                    // Success.
                    completionBlock(data, nil)
                } else {
                    if let error = error {
                        print("An error occurred: \(error)")
                    }
                    completionBlock(nil, error!)
                }
            })

    }
}
