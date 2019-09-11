# HSGoogleDrivePicker
A sane and simple file picker for Google Drive.

Google makes it ridiculously painful to select a file from Google Drive. 

For many use-cases, all you want is to present a picker, and get a notification when your user has selected a file.

This is the API that Google should have written.

![Picker Screenshot](https://raw.githubusercontent.com/ConfusedVorlon/HSGoogleDrivePicker/master/images/iPadPicker.png)


## Example



```swift

import HSGoogleDrivePicker

let picker = HSDrivePicker()

picker.pick(from: self) {
    (manager, file) in

    print("picked file: \(file?.name ?? "-none-")")
}

```

---
## Updating from 2.0 to 3.0

- Use the picker initialisation above
- Follow the ‘Configure the sign in process’ section below

---
## Installing HSGoogleDrivePicker

You can install HSGoogleDrivePicker in your project by using [CocoaPods](https://github.com/cocoapods/cocoapods)


```Ruby
pod 'HSGoogleDrivePicker', '~> 3.0’

```


## Getting your API keys

- Follow [Google’s guide](https://developers.google.com/drive/v3/web/quickstart/ios) (Step 1 only).
- Enable the Drive API permission. (click on ‘APIs and Auth’, ‘APIs’, then search for ‘Drive’) 

## Configure the sign in process

- Download a [configuration file from Google](https://developers.google.com/mobile/add?platform=ios&cntapi=signin)
- Add the configuration file to your project 
- Or manually configure GoogleSignIn by calling `GIDSignIn.sharedInstance().clientID = "YOUR_CLIENT_ID"` in your appDelegate


- Add a URL scheme to your project

1. Open your project configuration: double-click the project name in the left tree view. Select your app from the TARGETS section, then select the Info tab, and expand the URL Types section.
1. Click the + button, and add a URL scheme for your reversed client ID. To find this value, open the GoogleService-Info.plist configuration file, and look for the REVERSED_CLIENT_ID key. Copy the value of that key, and paste it into the URL Schemes box on the configuration page. Leave the other fields blank.

When completed, your config should look something similar to the following (but with your application-specific values)

![Picker Screenshot](https://raw.githubusercontent.com/ConfusedVorlon/HSGoogleDrivePicker/master/images/url_scheme.png)

- Handle the url callback in your app delegate

In YourAppDelegate.m


```swift

import HSGoogleDrivePicker

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

    if HSDrivePicker.handle(url) {
        return true
    }

    //Your code for other callbacks

    return true
}

```

---
## Usage

Create and show the picker


```swift
    
import HSGoogleDrivePicker

let picker = HSDrivePicker()

picker.pick(from: self) {
    (manager, file) in

    print("picked file: \(file?.name ?? "-none-")")
}
    
```

The completion handler returns with a GTLRDrive_File which has all the info you need. 

To download the file, use 

```swift
       
manager?.downloadFile(file, toPath: destinationPath, withCompletionHandler: { 
    error in

    if error != nil {
        print("Error downloading : \(error?.localizedDescription ?? "")")
    } else {
        print("Success downloading to : \(destinationPath)")
    }
})
```

---
## Status

I welcome pull requests.

## License

HSGoogleDrivePicker is available under the MIT license. See the LICENSE file for more info.
