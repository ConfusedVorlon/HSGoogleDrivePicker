//
//  ViewController.h
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSDriveManager.h"

@class GTLDriveFile;

typedef void (^GDriveFileViewerCompletionBlock)(HSDriveManager *manager, GTLDriveFile *file);

@interface HSDriveFileViewer : UIViewController

/** completion called when file viewer is closed **/
@property (copy) GDriveFileViewerCompletionBlock completion;

/** Initialise the viewer with your API secred and id **/
- (instancetype)initWithId:(NSString*)clientId secret:(NSString*)secret;

@end
