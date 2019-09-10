//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

import GoogleAPIClientForREST

extension GTLRDrive_File {
    func isFolder() -> Bool {
        return mimeType == "application/vnd.google-apps.folder"
    }
    
    var downloadUrlString:String? {
        
        guard let identifier = identifier, identifier.count != 0  else {
            return nil
        }

        let urlString = "https://www.googleapis.com/drive/v3/files/\(identifier)?alt=media"
        return urlString
    }
    
    var downloadURL:URL? {
        guard let downloadUrlString = downloadUrlString else {
            return nil
        }
        return URL.init(string: downloadUrlString)
    }
}
