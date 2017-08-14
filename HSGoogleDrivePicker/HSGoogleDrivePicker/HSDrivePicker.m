//
//  GDrivePicker.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "HSDrivePicker.h"
#import "HSDriveFileViewer.h"
#import "HSGIDSignInHandler.h"

#import <Google/SignIn.h>

@interface HSDrivePicker ()

@property (retain) HSDriveFileViewer *viewer;
@property (assign) UIStatusBarStyle thePreferredStatusBarStyle;

@end

@implementation HSDrivePicker
    
+(Boolean)handleURL:(NSURL*)url
{
    [HSGIDSignInHandler sharedInstance];
    if ([[GIDSignIn sharedInstance] handleURL:url
                            sourceApplication:@"com.apple.SafariViewService"
                                   annotation:nil]) {
        return YES;
        
    }
    
    return NO;
}

- (instancetype)initWithSecret:(NSString*)secret
{
    HSDriveFileViewer *viewer=[[HSDriveFileViewer alloc] initWithSecret:secret];
    if (!viewer)
    {
        return NULL;
    }
    
    self = [super initWithRootViewController:viewer];
    if (self) {
        self.preferredStatusBarStyle=UIStatusBarStyleDefault;
        self.modalPresentationStyle=UIModalPresentationPageSheet;
        self.viewer=viewer;
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.thePreferredStatusBarStyle;
}

-(void)setPreferredStatusBarStyle:(UIStatusBarStyle)thePreferredStatusBarStyle {
    self.thePreferredStatusBarStyle = thePreferredStatusBarStyle;
}



-(void)pickFromViewController:(UIViewController*)vc withCompletion:(void (^)(HSDriveManager *manager, GTLDriveFile *file))completion
{
    self.viewer.completion=completion;
    
    [vc presentViewController:self
                       animated:YES
                     completion:nil];
}

- (void)downloadFileContentWithService:(GTLServiceDrive *)service
                                  file:(GTLDriveFile *)file
                       completionBlock:(void (^)(NSData *, NSError *))completionBlock
{
    
    if (file.downloadUrl != nil)
    {
        GTMSessionFetcher *fetcher = [service.fetcherService fetcherWithURLString:file.downloadUrl];
        
        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            if (error == nil) {
                // Success.
                completionBlock(data, nil);
            } else {
                NSLog(@"An error occurred: %@", error);
                completionBlock(nil, error);
            }
        }];
    } else {
        completionBlock(nil,
                        [NSError errorWithDomain:NSURLErrorDomain
                                            code:NSURLErrorBadURL
                                        userInfo:nil]);
    }
}

@end
