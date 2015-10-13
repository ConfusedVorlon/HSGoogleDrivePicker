//
//  ViewController.m
//  gtest1
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "HS_GDrivePicker.h"
#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *result;

@end

@implementation ViewController

- (IBAction)pickFile:(id)sender {
    
    HS_GDrivePicker.h *picker=[[HS_GDrivePicker.h alloc] initWithId:@"YOUR ID HERE"
                                                   secret:@"YOUR SECRET HERE"];
    
    [picker pickFromViewController:self
                    withCompletion:^(GTLDriveFile *file) {
                        [self.result setText:[file title]];
                    }];
}


@end
