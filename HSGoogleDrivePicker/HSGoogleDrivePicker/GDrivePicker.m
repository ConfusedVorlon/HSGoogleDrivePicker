//
//  GDrivePicker.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "GDrivePicker.h"
#import "GDriveFileViewer.h"

@interface GDrivePicker ()

@property (retain) GDriveFileViewer *viewer;

@end

@implementation GDrivePicker

- (instancetype)initWithId:(NSString*)clientId secret:(NSString*)secret
{
    GDriveFileViewer *viewer=[[GDriveFileViewer alloc] initWithId:clientId secret:secret];
    if (!viewer)
    {
        return NULL;
    }
    
    self = [super initWithRootViewController:viewer];
    if (self) {
        self.modalPresentationStyle=UIModalPresentationPageSheet;
        self.viewer=viewer;
    }
    return self;
}

-(void)pickFromViewController:(UIViewController*)vc withCompletion:(void (^)(GTLDriveFile *file))completion;
{
    self.viewer.completion=completion;
    
    [vc presentViewController:self
                       animated:YES
                     completion:nil];
}

@end
