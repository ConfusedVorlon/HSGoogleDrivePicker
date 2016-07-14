//
//  GTLDriveFile.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "GTLDriveFile+HS.h"
#import <GoogleAPIClient/GTLDrive.h>


@implementation GTLDriveFile (HS_Helpers)

-(BOOL)isFolder
{
    return [self.mimeType isEqualToString:@"application/vnd.google-apps.folder"];
}

-(NSString*)downloadUrl;
{
    if (self.identifier.length == 0)
    {
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?alt=media",
                           self.identifier];
    return urlString;
}

@end
