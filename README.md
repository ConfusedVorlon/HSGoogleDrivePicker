# HSGoogleDrivePicker
A sane and simple file picker for Google Drive.

Google makes it ridiculously painful to select a file from Google Drive. 

For many use-cases, all you want is to present a picker, and get a notification when your user has selected a file.

This is the API that Google should have written.

![Picker Screenshot](https://raw.githubusercontent.com/ConfusedVorlon/HSGoogleDrivePicker/master/images/iPadPicker.png)


## Example

`#import "HSDrivePicker.h"`

```objective-c
    
HSDrivePicker *picker=[[HSDrivePicker alloc] initWithSecret:@"YOUR SECRET HERE"];
    
[picker pickFromViewController:self
                withCompletion:^(HSDriveManager *manager, GTLDriveFile *file) {
                        NSLog(@"selected: %@",file.title);
                    }];
```

## Getting Started

- Install HSGoogleDrivePicker via CocoaPods or by downloading the Source files
- Follow the Google guide to set up your API keys
- Run a picker.


---
##Installing HSGoogleDrivePicker

You can install HSGoogleDrivePicker in your project by using [CocoaPods](https://github.com/cocoapods/cocoapods)


```Ruby
pod 'HSGoogleDrivePicker', '~> 2.0’

```


## Getting your API keys

- Follow [Google’s guide](https://developers.google.com/drive/ios/quickstart) (Step 1 only).
- Enable the Drive API permission. (click on ‘APIs and Auth’, ‘APIs’, then search for ‘Drive’) 

## Configure the sign in process

- Download a [configuration file from Google](https://developers.google.com/mobile/add?platform=ios&cntapi=signin)
- Add the configuration file to your project
- Add a URL scheme to your project

1. Open your project configuration: double-click the project name in the left tree view. Select your app from the TARGETS section, then select the Info tab, and expand the URL Types section.
1. Click the + button, and add a URL scheme for your reversed client ID. To find this value, open the GoogleService-Info.plist configuration file, and look for the REVERSED_CLIENT_ID key. Copy the value of that key, and paste it into the URL Schemes box on the configuration page. Leave the other fields blank.

When completed, your config should look something similar to the following (but with your application-specific values)

![Picker Screenshot](https://raw.githubusercontent.com/ConfusedVorlon/HSGoogleDrivePicker/master/images/url_scheme.png)

-Handle the url callback in your app delegate

In YourAppDelegate.m

`#import "HSDrivePicker.h"`

```objective-c

//Depending on which delegate methods you support…

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url

//this version works from iOS 9 onwards
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
	if ([HSDrivePicker  handleURL:url]) {
        return YES;
    }

//Your code for other callbacks

	return YES
}

// to support 
    

```

## Usage

Run the example code above using your keys.

The completion handler returns with a GTLDriveFile which has all the info you need. 

`#import "HSDrivePicker.h"`

```objective-c
    
HSDrivePicker *picker=[[HSDrivePicker alloc] initWithId:@"YOUR ID HERE"
                                                   secret:@"YOUR SECRET HERE"];
    
[picker pickFromViewController:self
                withCompletion:^(HSDriveManager *manager, GTLDriveFile *file) {
                        NSLog(@"selected: %@",file.title);
                    }];
```

To download the file, use 

```objective-c
       
[manager downloadFile:file
               toPath:fullPath
withCompletionHandler:^(NSError *error) {

	if (error)
	{
		NSLog(@"Error downloading");
	}
	else
	{
		NSLog(@"Success");
	}
}];
```

## Status

HSGoogleDrivePicker is simplistic and new, but I’m using it in production code. 

I welcome pull requests.

## License

HSGoogleDrivePicker is available under the MIT license. See the LICENSE file for more info.