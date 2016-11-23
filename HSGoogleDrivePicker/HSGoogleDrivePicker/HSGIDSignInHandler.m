//
//  HSGIDSignInDelegate.m
//  Pods
//
//  Created by Rob Jonson on 23/11/2016.
//
//

#import "HSGIDSignInHandler.h"
#import <GoogleAPIClient/GTLDrive.h>

@interface HSGIDSignInHandler ()
    
    @property (retain) id<GTMFetcherAuthorizationProtocol> authoriser;
    
    @end

@implementation HSGIDSignInHandler
    
    
+ (HSGIDSignInHandler *)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [HSGIDSignInHandler new];
    });
    return sharedInstance;
}

-(id)init
{
    self=[super init];
    if (self)
    {
        NSError *configureError=NULL;
        [[GGLContext sharedInstance] configureWithError:&configureError];
        NSAssert(configureError==nil, @"Problem configuring Google Sign in");
        
        [[GIDSignIn sharedInstance] setDelegate:self ];
        
        NSArray *currentScopes = [GIDSignIn sharedInstance].scopes;
        [GIDSignIn sharedInstance].scopes = [currentScopes arrayByAddingObject:kGTLAuthScopeDrive];
    }
    
    return self;
}

+(id<GTMFetcherAuthorizationProtocol>)authoriser
{
    return self.sharedInstance.authoriser;
}
    
+(BOOL)canAuthorise
{
    if (self.sharedInstance.authoriser.canAuthorize){
        return YES;
    }
    
    return NO;
}
    
+(void)signInFromViewController:(UIViewController*)vc {
    
    [self sharedInstance];
    
    //in iOS 8, the sign-in is called with view_did_appear before the signIn_didSignIn is fired on a queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [GIDSignIn sharedInstance].uiDelegate = vc;
        [[GIDSignIn sharedInstance] signIn];
    });
    
}
    
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user  withError:(NSError *)error
{
    self.authoriser = [user.authentication fetcherAuthorizer];
    
    if (!error){
        [[NSNotificationCenter defaultCenter] postNotificationName:HSGIDSignInChangedNotification
                                                            object:self];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:HSGIDSignInFailedNotification
                                                            object:self];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Unable to sign in to Drive"
                                                     message:error.localizedDescription
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
}
    
    
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    NSLog(@"User disconnected");
    [[NSNotificationCenter defaultCenter] postNotificationName:HSGIDSignInChangedNotification
                                                        object:self];
}
    
    @end
