//
//  GDrivePicker.h
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleAPIClient/GTLDrive.h>
#import "HSDriveManager.h"

@interface HSDrivePicker : UINavigationController

/** Provide your API id & secret **/
- (instancetype)initWithId:(NSString*)clientId secret:(NSString*)secret;

/** Present the picker from your view controller. It will present as a modal form.
 The completion returns both the file, and the authorised manager which can be used to download the file **/
-(void)pickFromViewController:(UIViewController*)vc withCompletion:(void (^)(HSDriveManager *manager, GTLDriveFile *file))completion;


/*

Appearance can mostly be managed through the appearance proxy.
e.g.  [[UINavigationBar appearance] setBackgroundImage: <your image> ];
 
 or to style the segmented control (which is addmittedly wierd)
 
 //selected text
 [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateSelected];
 //not selected text
 [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor greenColor]} forState:UIControlStateNormal];
 //background
 [[UIImageView appearanceWhenContainedIn:[UISegmentedControl class],nil] setTintColor:[UIColor blueColor]];
 
*/


/**specify status bar style. Default is UIStatusBarStyleDefault **/
@property (assign) UIStatusBarStyle preferredStatusBarStyle;

@end
