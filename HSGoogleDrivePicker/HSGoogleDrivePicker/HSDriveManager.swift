import GoogleAPIClientForREST

private let kKeychainItemName = "Drive API"


/// Manage interaction with Drive
/// Drive manager is declared as an NSObject so that the completion handler in DrivePicker.pick(...) can be represented in Obj-C
@objcMembers open class HSDriveManager:NSObject {
    //* called by view controller when auth changes after a sign in *
    
    
    //* runs a fetch with the current search settings. Cancels any outstanding fetch *
    
    
    /** If the download completes succesfully, then the completion handler will be called with NULL for the error
     returns GTMHTTPFetcher - this can be used to monitor download progress.
     **/
    
    
    //* if No, shows 'my files'. Default is NO *
    open var sharedWithMe = false
    //* initially 'root'. Ignored if sharedWithMe is selected *
    open var folderId:String = "root"
    //* Default is NO *
    open var showTrashed = false
    //* Default is 1000 *
    open var maxResults = 1000
    //* Default is YES. This is not recommended by Google, but I don't want to implement multi-page logic *
    open var autoFetchPages = false
    //* Default is 'Sign out'*
    open var signOutLabel:String = "Sign out"
    
    private var service: GTLRDriveService?
    
    override init() {

        // Initialize the Drive API service & load existing credentials from the keychain if available.
        service = GTLRDriveService()
        
        service?.authorizer = HSGIDSignInHandler.authoriser
    }
    
    // MARK: download
    @discardableResult
    @objc public func downloadFile(_ file: GTLRDrive_File?, toPath path: String, withCompletionHandler handler: @escaping (_ error: Error?) -> Void) -> GTMSessionFetcher? {
        
        guard let downloadURL = file?.downloadURL else {
            return nil
        }
        
        let destinationUrl = URL(fileURLWithPath: path)
        
        let fetcher = service?.fetcherService.fetcher(with: downloadURL)
        fetcher?.destinationFileURL = destinationUrl
        
        fetcher?.beginFetch(completionHandler: { data, error in
            if error == nil {
                // Success.
                handler(nil)
            } else {

                if let error = error {
                    print("An error occurred: \(error)")
                }
                if let data = (error as NSError?)?.userInfo["data"] as? Data  {
                    let dError = String(data: data, encoding: .utf8)
                    print("Error data: \(String(describing: dError))")
                }
                handler(error)
            }
        })
        
        return fetcher
    }
    
    // MARK: file listing
    var filterQuery:String {
        var query = "'\(folderId)' in parents"
        if sharedWithMe {
            query = "sharedWithMe"
        }
        
        if !showTrashed {
            query = query + (" and trashed = false")
        }

        return query
    }
    
    // Construct a query to get names and IDs of files using the Google Drive API.
    func fetchFiles(withCompletionHandler handler: @escaping GTLRServiceCompletionHandler) {
        
        service?.shouldFetchNextPages = autoFetchPages
        
        let query = GTLRDriveQuery_FilesList.query()
        
        query.q = self.filterQuery
        query.fields = "files(id,kind,mimeType,name,size,iconLink)"
        
        
        query.pageSize = maxResults
        
        service?.executeQuery(query, completionHandler: handler)
        
    }
    
    // MARK: auth controller
    func updateAuthoriser() {
        service?.authorizer = HSGIDSignInHandler.authoriser
    }
}
