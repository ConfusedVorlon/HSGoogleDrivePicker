//
//  ViewController.m
//  HSGoogleDrivePicker-Demo
//
//  Created by Rob Jonson on 14/08/2017.
//  Copyright © 2017 HobbyistSoftware. All rights reserved.
//

#import "ViewController.h"
#import "HSDrivePicker.h"

//REQUIRED STEPS TO RUN DEMO
// 1) Provide your secret below
// 2) Add your 'GoogleService-Info.plist' plist to the project
// 3) Configure the correct callback URL
//
// See documentation for full details: https://github.com/ConfusedVorlon/HSGoogleDrivePicker#getting-your-api-keys



@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *pickedFile;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickFile:(id)sender {
    
    HSDrivePicker *picker=[[HSDrivePicker alloc] initWithSecret:@"YOUR SECRET HERE"];
    
    
    [picker pickFromViewController:self
                    withCompletion:^(HSDriveManager *manager, GTLDriveFile *file) {
                        //update the label
                        self.pickedFile.text = [NSString stringWithFormat: @"selected: %@",file.name];
                        
                        //Download the file
                        NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:file.name];
                        [manager downloadFile:file toPath:destinationPath withCompletionHandler:^(NSError *error) {
                            
                            if (error)
                            {
                                NSLog(@"Error downloading : %@", error.localizedDescription);
                            }
                            else
                            {
                                NSLog(@"Success downloading to : %@", destinationPath);
                            }
                            
                        }];
                    }];
}





@end
