//
//  ViewController.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "HS_GDriveFileViewer.h"
#import "HS_GDriveManager.h"
#import "AsyncImageView.h"



@interface HS_GDriveFileViewer () <UITableViewDataSource,UITableViewDelegate>



@property (retain) UILabel *output;
@property (retain) UIActivityIndicatorView *activity;

@property (retain) HS_GDriveManager *manager;
@property (retain) UITableView *table;
@property (retain) GTLDriveFileList *fileList;
@property (retain) UIImage *blankImage;
@property (retain) UIBarButtonItem *upItem;
@property (retain) UIBarButtonItem *doneItem;
@property (retain) NSMutableArray *folderTrail;
@property (assign) BOOL showShared;


@end


@implementation HS_GDriveFileViewer




- (instancetype)initWithId:(NSString*)clientId secret:(NSString*)secret
{
    self = [super init];
    if (self)
    {
        [self setTitle:@"Google Drive"];
        
        self.manager=[[HS_GDriveManager alloc] initWithId:clientId secret:secret];
        self.modalPresentationStyle=UIModalPresentationPageSheet;
        
        UIGraphicsBeginImageContext(CGSizeMake(40, 40));
        CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 40, 40)); // this may not be necessary
        self.blankImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.folderTrail=[NSMutableArray arrayWithObject:@"root"];
    }
    return self;
}

// When the view loads, create necessary subviews, and initialize the Drive API service.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    // Create a UITextView to display output.
    UILabel *output=[[UILabel alloc] initWithFrame:CGRectMake(40, 60, self.view.bounds.size.width-80, 40)];
    output.textAlignment=NSTextAlignmentCenter;
    output.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:output];
    self.output=output;
    
    
    UIActivityIndicatorView *activity=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity setCenter:CGPointMake(self.view.center.x, 150)];
    [activity setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [activity setColor:self.view.tintColor];
    [activity setHidesWhenStopped:YES];
    [self.view addSubview:activity];
    
    self.activity=activity;
    
    UITableView *tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    tableView.contentInset=UIEdgeInsetsMake(44, 0, 0, 0);
    tableView.scrollIndicatorInsets=UIEdgeInsetsMake(44, 0, 0, 0);
    
    [self.view addSubview:tableView];
    self.table=tableView;
    
    [self setupButtons];
    [self updateButtons];
    
}

// When the view appears, ensure that the Drive API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated
{
    UIViewController *authVC=[self.manager authorisationViewController];
    
    if (authVC)
    {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        UINavigationController *nc=(UINavigationController *)[self parentViewController];
        [nc pushViewController:authVC animated:YES];
        
    }
    else
    {
        [self getFiles];
    }
}

-(void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getFiles
{
    self.manager.sharedWithMe=self.showShared;
    self.fileList=NULL;
    
    [self updateDisplay];
    [self.activity startAnimating];
    [self updateButtons];
    [self.output setText:@"Loading"];
    
    [self.manager fetchFilesWithCompletionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *fileList, NSError *error)
     {
         [self.activity stopAnimating];
         
         if (error)
         {
             NSString *message=[NSString stringWithFormat:@"Error: %@",error.localizedDescription ];
             [self.output setText:message];
         }
         else
         {
             self.fileList=fileList;
         }
         
         [self updateDisplay];
         
     }];
}

-(void)updateDisplay
{
    [self updateButtons];
    
    if (self.fileList)
    {
        if (self.fileList.items.count)
        {
            [self.table setHidden:NO];
            [self.table reloadData];
        }
        else
        {
            [self.output setText:@"Folder is empty"];
            [self.table setHidden:YES];
        }
    }
    else
    {
        [self.table setHidden:YES];
    }
}


-(void)setupButtons
{
    NSArray *segItemsArray = [NSArray arrayWithObjects: @"Mine",@"Shared", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(mineSharedChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 100, 30);
    segmentedControl.selectedSegmentIndex = 0;
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    
    self.doneItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                target:self
                                                                action:@selector(cancel:)];
    
    self.upItem=[[UIBarButtonItem alloc] initWithTitle:@"Up"
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(up:)];
    
    
    
    [self.navigationItem setRightBarButtonItem:segmentedControlButtonItem
                                      animated:YES];
}

-(void)updateButtons
{

    
    if ([self.folderTrail count]>1 && !self.showShared)
    {
        [self.navigationItem setLeftBarButtonItems:@[self.doneItem,self.upItem]
                                          animated:YES];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItems:@[self.doneItem]
                                          animated:YES];
    }

}

#pragma mark searching

-(void)mineSharedChanged:(UISegmentedControl*)sender
{
    self.showShared=([sender selectedSegmentIndex]==1);
  
    [self getFiles];
}

-(void)up:(id)sender
{
    if ([self.folderTrail count]>1)
    {
        [self.folderTrail removeLastObject];
        [self.manager setFolderId:self.folderTrail.lastObject];
        [self getFiles];
    }
}

-(void)openFolder:(GTLDriveFile *)file
{
    NSString *folderId=[file identifier];
    NSString *currentFolder=[self.folderTrail lastObject];
    
    if ([folderId isEqualToString:currentFolder])
    {
        return;
    }
    
    else
    {
        [self.folderTrail addObject:folderId];
        [self.manager setFolderId:file.identifier];
        [self getFiles];
    }
}



#pragma mark table

-(GTLDriveFile*)fileForIndexPath:(nonnull NSIndexPath *)indexPath
{
    return [self.fileList.items objectAtIndex:[indexPath row]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileList.items count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *identifier=@"HS_GDriveFileViewer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UIImageView *iv=cell.imageView;
        [iv setImage:self.blankImage];
        
        AsyncImageView *async=[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [async setContentMode:UIViewContentModeCenter];
        
        [iv addSubview:async];
    }
    
    GTLDriveFile *file=[self fileForIndexPath:indexPath];
    [cell.textLabel setText:file.title];
    
    NSLog(@"mime: %@",file.mimeType);
    
    AsyncImageView *async=(AsyncImageView *)[cell.imageView.subviews firstObject];
    
    [async setImageURL:[NSURL URLWithString:file.iconLink]];
    if (file.thumbnailLink)
    {
        [async setImageURL:[NSURL URLWithString:file.thumbnailLink]];
        
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTLDriveFile *file=[self fileForIndexPath:indexPath];
    if ([file isFolder])
    {
        [self openFolder:file];
    }
    else
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     self.completion(file);
                                 }];
    }
}



@end
