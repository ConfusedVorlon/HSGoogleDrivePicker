//
//  ViewController.m
//  HSGoogleDrivePicker-Demo
//
//  Created by Rob Jonson on 14/08/2017.
//  Copyright © 2017 HobbyistSoftware. All rights reserved.
//

import HSGoogleDrivePicker
import UIKit

class ViewController: UIViewController, UINavigationBarDelegate {

    
    @IBOutlet weak var pickedFile: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    @IBAction func pickFile(_ sender: Any) {
        
        let picker = HSDrivePicker(secret: "YOUR SECRET HERE")
        
        
        picker?.pick(from: self, withCompletion: { manager, file in
            //update the label
            if let name = file?.name {
                self.pickedFile.text = "selected: \(name)"
            }
            
            //Download the file
            guard let fileName = file?.name else {
                print("Error: File has no name")
                return
            }
            
            let destURL =  URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            let destinationPath = destURL.absoluteString
            manager?.downloadFile(file, toPath: destinationPath, withCompletionHandler: { error in
                
                if error != nil {
                    print("Error downloading : \(error?.localizedDescription ?? "")")
                } else {
                    print("Success downloading to : \(destinationPath)")
                }
                
            })
        })
    }
}
