//
//  ViewController.h
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLDriveFile;

typedef void (^GDriveFileViewerCompletionBlock)(GTLDriveFile *file);

@interface HS_GDriveFileViewer : UIViewController

@property (copy) GDriveFileViewerCompletionBlock completion;

- (instancetype)initWithId:(NSString*)clientId secret:(NSString*)secret;

@end
