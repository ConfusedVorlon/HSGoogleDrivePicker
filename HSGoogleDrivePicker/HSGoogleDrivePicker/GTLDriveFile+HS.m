//
//  GTLDriveFile.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "GTLDriveFile+HS.h"
#import "GTLDrive.h"

@implementation GTLDriveFile (HS_Helpers)

-(BOOL)isFolder
{
    return [self.mimeType isEqualToString:@"application/vnd.google-apps.folder"];
}

@end
