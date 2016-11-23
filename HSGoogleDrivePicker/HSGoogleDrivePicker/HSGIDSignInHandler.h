//
//  HSGIDSignInDelegate.h
//  Pods
//
//  Created by Rob Jonson on 23/11/2016.
//
//

#import <Foundation/Foundation.h>
#import <Google/SignIn.h>

#define HSGIDSignInChangedNotification @"HSGIDSignInChangedNotification"
#define HSGIDSignInFailedNotification @"HSGIDSignInFailedNotification"

@interface HSGIDSignInHandler : NSObject <GIDSignInDelegate>

    
    + (HSGIDSignInHandler *)sharedInstance;
    
    +(id<GTMFetcherAuthorizationProtocol>)authoriser;
    +(BOOL)canAuthorise;
    +(void)signInFromViewController:(UIViewController*)vc;
    
@end
