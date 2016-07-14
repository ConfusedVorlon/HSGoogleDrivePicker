//
//  GDriveManager.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "HSDriveManager.h"
#import <GTMOAuth2/GTMOAuth2ViewControllerTouch.h>


static NSString *const kKeychainItemName = @"Drive API";

@interface HSDriveManager ()

@property (retain) NSString *clientId;
@property (retain) NSString *clientSecret;
@property (nonatomic, strong) GTLServiceDrive *service;
@property (retain) GTMOAuth2ViewControllerTouch *authController;

@end

@implementation HSDriveManager

- (instancetype)initWithId:(NSString*)clientId secret:(NSString*)secret
{
    self = [super init];
    if (self) {
        
        self.clientId=clientId;
        self.clientSecret=secret;
        
        // Initialize the Drive API service & load existing credentials from the keychain if available.
        self.service = [[GTLServiceDrive alloc] init];
        self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                              clientID:self.clientId
                                                          clientSecret:self.clientSecret];
        
        self.folderId=@"root";
        self.maxResults=1000;
        
    }
    return self;
}

#pragma mark download

-(GTMSessionFetcher*)downloadFile:(GTLDriveFile*)file toPath:(NSString*)path withCompletionHandler:(void (^)(NSError *error))handler
{
    GTMSessionFetcher *fetcher = [self.service.fetcherService fetcherWithURLString:file.downloadUrl];
    NSURL* destinationUrl=[NSURL fileURLWithPath:path];
    [fetcher setDestinationFileURL:destinationUrl];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            // Success.
            handler( nil);
        } else {
            NSLog(@"An error occurred: %@", error);
            handler( error);
        }
    }];
    
    return fetcher;
}

#pragma mark file listing

-(NSString*)query
{
    NSString *query=[NSString stringWithFormat:@"'%@' in parents", self.folderId];
    if (self.sharedWithMe)
    {
        query=@"sharedWithMe";
    }
    
    if (!self.showTrashed)
    {
        query=[query stringByAppendingString:@" and trashed = false"];
    }

    
    return query;
}

// Construct a query to get names and IDs of files using the Google Drive API.
- (void)fetchFilesWithCompletionHandler:(void (^)(GTLServiceTicket *ticket, GTLDriveFileList *fileList, NSError *error))handler
{
    
    self.service.shouldFetchNextPages = self.autoFetchPages;
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    
    query.q=[self query];
    query.fields=@"files(id,kind,mimeType,name,size,iconLink)";
    
    
    query.pageSize = self.maxResults;
    
    [self.service executeQuery:query
             completionHandler:handler];
   
}



#pragma mark auth controller


-(UIViewController*)authorisationViewController
{
    if (!self.service.authorizer.canAuthorize)
    {
        self.authController=[self createAuthController];
        return self.authController;
    }
    else
    {
        return NULL;
    }
}

// Creates the auth controller for authorizing access to Drive API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDrive, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:self.clientId
                      clientSecret:self.clientSecret
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    UIBarButtonItem *done=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                        target:self
                                                                        action:@selector(cancel:)];
    [authController.navigationItem setLeftBarButtonItem:done animated:NO];
    
    return authController;
}

// Handle completion of the authorization process, and update the Drive API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil)
    {
        NSLog(@"Authentication Error: %@",error.localizedDescription);
        //TODO return error
        self.service.authorizer = nil;
    }
    else
    {
        self.service.authorizer = authResult;
        [self.authController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)cancel:(id)sender
{
    [self.authController dismissViewControllerAnimated:YES completion:nil];
}

@end
