//
//  GTLDriveFile.h
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import <GoogleAPIClient/GTLDriveFile.h>

@interface GTLDriveFile (HS_Helpers)

/** Is it a folder?
 returns true for folders
 **/
-(BOOL)isFolder;

/** Download url
 returns the url as a string constructed from the magic string found in stack overflow
 **/
-(NSString*)downloadUrl;

@end
