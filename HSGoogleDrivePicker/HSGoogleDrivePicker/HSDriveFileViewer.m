//
//  ViewController.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//

#import "HSDriveFileViewer.h"
#import "HSDriveManager.h"
#import "HSGIDSignInHandler.h"
#import "AsyncImageView.h"
#import "UIScrollView+SVPullToRefresh.h"


@interface HSDriveFileViewer () <UITableViewDataSource,UITableViewDelegate>



@property (retain) UILabel *output;

@property (retain) HSDriveManager *manager;
@property (retain) UITableView *table;
@property (assign) UIToolbar *toolbar;
@property (retain) GTLDriveFileList *fileList;
@property (retain) UIImage *blankImage;
@property (retain) UIBarButtonItem *upItem;
@property (retain) UIBarButtonItem *segmentedControlButtonItem;
@property (retain) NSMutableArray *folderTrail;
@property (assign) BOOL showShared;
@property (retain) NSString * signInLabel;
@property (retain) NSString * signOutLabel;
@property (retain) UIBarButtonItem *signOutButton;



@end


@implementation HSDriveFileViewer


- (instancetype)initWithSecret:(NSString*)secret
{
    self = [super init];
    if (self)
    {
        [self setTitle:@"Google Drive"];
        _signInLabel = @"Sign In";
        _signOutLabel = @"Sign Out";
        
        self.manager=[[HSDriveManager alloc] initWithId:[self clientId]
                                                 secret:secret];
        self.modalPresentationStyle=UIModalPresentationPageSheet;
        
        UIGraphicsBeginImageContext(CGSizeMake(40, 40));
        CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 40, 40)); // this may not be necessary
        self.blankImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.folderTrail=[NSMutableArray arrayWithObject:@"root"];
    }
    return self;
}
    
- (void) setSignInLabel:(NSString*)signInLabelParam{
    _signInLabel = signInLabelParam;
}

- (void) setSignOutLabel:(NSString*)signOutLabelParam{
    _signOutLabel = signOutLabelParam;
}

-(NSString*)clientId
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *clientID = [dict objectForKey:@"CLIENT_ID"];
    return clientID;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Create a UITextView to display output.
    UILabel *output=[[UILabel alloc] initWithFrame:CGRectMake(40, 100, self.view.bounds.size.width-80, 40)];
    output.numberOfLines=0;
    output.textAlignment=NSTextAlignmentCenter;
    output.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:output];
    self.output=output;
    
    UIToolbar *toolbar=[UIToolbar new];
    [toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.toolbar=toolbar;
    [self.view addSubview:toolbar];
    
    UITableView *tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [tableView addPullToRefreshWithActionHandler:^{
        [self getFiles];
    }];
    
    [self.view addSubview:tableView];
    self.table=tableView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toolbar,tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[toolbar]|"
                                                                      options:NSLayoutFormatDirectionLeftToRight
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|"
                                                                      options:NSLayoutFormatDirectionLeftToRight
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(44)][tableView]|"
                                                                      options:NSLayoutFormatDirectionLeftToRight
                                                                      metrics:nil
                                                                        views:views]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authFailed)
                                                 name:HSGIDSignInFailedNotification
                                               object:nil];
    

    
    [self setupButtons];
    [self updateButtons];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// When the view appears, ensure that the Drive API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authUpdated)
                                                 name:HSGIDSignInChangedNotification
                                               object:nil];
    
    if ([HSGIDSignInHandler canAuthorise])
    {
        //after first sign in, the authoriser is updated before viewDidAppear is called
        [self.manager updateAuthoriser];
        [self getFiles];
        [_signOutButton setTitle:_signOutLabel];
    }
    else{
        [_signOutButton setTitle:_signInLabel];
    }
}

    
-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HSGIDSignInChangedNotification
                                                  object:nil];
    [super viewWillDisappear:animated];
}
    
-(void)authUpdated
{
    [self.manager updateAuthoriser];
    [self getFiles];
    [_signOutButton setTitle:_signOutLabel];
}
    
-(void)authFailed
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)toggleSign:(id)sender
{
    // Sign Out
    if ([HSGIDSignInHandler canAuthorise]){
        [HSGIDSignInHandler signOutFromViewController:self];
        [self dismissViewControllerAnimated:YES completion:nil];
        [_signOutButton setTitle:_signInLabel];
        
    }
    // Sign In
    else
    {
        [HSGIDSignInHandler signInFromViewController:self];
        [_signOutButton setTitle:_signOutLabel];
    }
}

-(void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getFiles
{
    if (self.table.pullToRefreshView.state==SVPullToRefreshStateStopped)
    {
        [self.table triggerPullToRefresh];
    }
    
    self.manager.sharedWithMe=self.showShared;
    self.fileList=NULL;
    
    [self updateDisplay];
    [self updateButtons];
    
    [self.manager fetchFilesWithCompletionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *fileList, NSError *error)
     {
         [self.table.pullToRefreshView stopAnimating];
         

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
        if (self.fileList.files.count)
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

}


-(void)setupButtons
{
    NSArray *segItemsArray = [NSArray arrayWithObjects: @"Mine",@"Shared", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(mineSharedChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 100, 30);
    segmentedControl.selectedSegmentIndex = 0;
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    self.segmentedControlButtonItem=segmentedControlButtonItem;
    
    UIBarButtonItem *doneItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                target:self
                                                                action:@selector(cancel:)];
    
    self.upItem=[[UIBarButtonItem alloc] initWithTitle:@"Up"
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(up:)];
    
    
    
    [self.navigationItem setLeftBarButtonItem:doneItem
                                      animated:YES];
    
    _signOutButton = [[UIBarButtonItem alloc] initWithTitle:_signOutLabel style:UIBarButtonItemStylePlain target:self action:@selector(toggleSign:)];
    [_signOutButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0], NSKernAttributeName: @2.0} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:_signOutButton];
}

-(void)updateButtons
{
    UIBarButtonItem *flex=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:nil
                                                                        action:nil];
    
    if ([self.folderTrail count]>1 && !self.showShared)
    {
        [self.toolbar setItems:@[self.upItem,flex,self.segmentedControlButtonItem] animated:YES];
    }
    else
    {
        [self.toolbar setItems:@[flex,self.segmentedControlButtonItem] animated:YES];
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
    return [self.fileList.files objectAtIndex:[indexPath row]];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileList.files count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *identifier=@"HSDriveFileViewer";
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
    
    AsyncImageView *async=(AsyncImageView *)[cell.imageView.subviews firstObject];
    GTLDriveFile *file=[self fileForIndexPath:indexPath];
    
    if (file)
    {
        [cell.textLabel setText:file.name];
        [async setImageURL:[NSURL URLWithString:file.iconLink]];
    }
    else
    {
        [cell.textLabel setText:NULL];
        [async setImage:NULL];
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
                                     self.completion(self.manager,file);
                                 }];
    }
}



@end
