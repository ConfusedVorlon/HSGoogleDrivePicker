import GoogleAPIClient

private let kKeychainItemName = "Drive API"

open class HSDriveManager {
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
    
    private var clientId:String
    private var clientSecret:String
    private var service: GTLServiceDrive?
    
    init(clientId newId: String, secret newSecret: String) {

        clientId = newId
        clientSecret = newSecret
        
        // Initialize the Drive API service & load existing credentials from the keychain if available.
        service = GTLServiceDrive()
        
        service?.authorizer = HSGIDSignInHandler.authoriser()
    }
    
    // MARK: download
    public func downloadFile(_ file: GTLDriveFile?, toPath path: String, withCompletionHandler handler: @escaping (_ error: Error?) -> Void) -> GTMSessionFetcher? {
        
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
    func query() -> String? {
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
    func fetchFiles(withCompletionHandler handler: @escaping GTLServiceCompletionHandler) {
        
        service?.shouldFetchNextPages = autoFetchPages
        
        guard let query = GTLQueryDrive.queryForFilesList() else {
            print("Error - no query for file list")
            return
        }
        
        query.q = self.query()
        query.fields = "files(id,kind,mimeType,name,size,iconLink)"
        
        
        query.pageSize = maxResults
        
        service?.executeQuery(query, completionHandler: handler)
        
    }
    
    // MARK: auth controller
    func updateAuthoriser() {
        service?.authorizer = HSGIDSignInHandler.authoriser()
    }
}
