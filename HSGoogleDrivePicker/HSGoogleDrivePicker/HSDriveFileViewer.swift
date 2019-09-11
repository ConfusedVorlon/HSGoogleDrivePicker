//  Converted to Swift 5 by Swiftify v5.0.30657 - https://objectivec2swift.com/
//
//  ViewController.m
//  gdrive
//
//  Created by Rob Jonson on 13/10/2015.
//  Copyright © 2015 HobbyistSoftware. All rights reserved.
//


import UIKit
import GoogleAPIClientForREST
import AsyncImageView

public typealias GDriveFileViewerCompletionBlock = (HSDriveManager?, GTLRDrive_File?) -> Void

/// Table View and controls to view files
open class HSDriveFileViewer: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //* completion called when file viewer is closed *
    open var completion: GDriveFileViewerCompletionBlock?
    
    //* Initialise the viewer with your id & API secret *
    
    
    //* tells view controller to pop up signin sheet if appropriate once it is visible *
    @objc open var shouldSignInOnAppear = false
    private var output: UILabel?
    private var manager: HSDriveManager = HSDriveManager()
    private var table: UITableView!
    private var toolbar: UIToolbar?
    private var fileList: GTLRDrive_FileList?
    private var blankImage: UIImage?
    private var upItem: UIBarButtonItem?
    private var segmentedControlButtonItem: UIBarButtonItem!
    private var folderTrail: [String] = []
    private var showShared = false
    
    init() {

        super.init(nibName: nil, bundle: nil)
        self.title = "Google Drive"
        
        
        modalPresentationStyle = UIModalPresentationStyle.pageSheet
        
        UIGraphicsBeginImageContext(CGSize(width: 40, height: 40))
        UIGraphicsGetCurrentContext()?.addRect(CGRect(x: 0, y: 0, width: 40, height: 40)) // this may not be necessary
        blankImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        folderTrail = ["root"]
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        
        view.backgroundColor = UIColor.white
        
        // Create a UITextView to display output.
        let output = UILabel(frame: CGRect(x: 40, y: 100, width: view.bounds.size.width - 80, height: 40))
        output.numberOfLines = 0
        output.textAlignment = .center
        output.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(output)
        self.output = output
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.toolbar = toolbar
        view.addSubview(toolbar)
        
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(getFiles), for: .valueChanged)

        
        view.addSubview(tableView)
        table = tableView
        
        let views:[String : Any] = [
                     "toolbar" : toolbar,
                     "tableView" : tableView
                     ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[toolbar]|", options: .directionLeftToRight, metrics: nil, views: views))


        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: .directionLeftToRight, metrics: nil, views: views))


        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[toolbar(44)][tableView]|", options: .directionLeftToRight, metrics: nil, views: views))

        
        NotificationCenter.default.addObserver(self, selector: #selector(authFailed), name: HSGIDSignInHandler.hsGIDSignInFailedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(authUpdated), name: HSGIDSignInHandler.hsGIDSignInChangedNotification, object: nil)
        
        setupButtons()
        updateButtons()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // When the view appears, ensure that the Drive API service is authorized, and perform API calls.
    override open func viewDidAppear(_ animated: Bool) {
        
        
        
        if HSGIDSignInHandler.canAuthorise() {
            //after first sign in, the authoriser is updated before viewDidAppear is called
            
            getFiles()
        } else if shouldSignInOnAppear {
            shouldSignInOnAppear = false
            HSGIDSignInHandler.signIn(from: self)
        }
        
        updateRightButton()
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
    }
    
    @objc func authUpdated() {
        getFiles()
    }
    
    func updateRightButton() {
        let signOutButton = UIBarButtonItem(title: manager.signOutLabel, style: .plain, target: self, action: #selector(signOut))
        
        navigationItem.rightBarButtonItem = signOutButton
        
    }
    
    @objc func signOut() {
        HSGIDSignInHandler.signOut()
        dismiss(animated: true)
    }
    
    @objc func authFailed() {
        dismiss(animated: true)
    }
    
    @objc func cancel(_ sender: Any?) {
        dismiss(animated: true)
    }
    
    @objc
    func getFiles() {
        
        if let refreshControl = table.refreshControl {
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            }
        }
        
        manager.updateAuthoriser()
        manager.sharedWithMe = showShared
        fileList = nil
        
        updateDisplay()
        updateButtons()
        
        manager.fetchFiles(withCompletionHandler: { ticket, fileList, error in
            self.table?.refreshControl?.endRefreshing()
            
            if error != nil {
                let message = "Error: \(error?.localizedDescription ?? "")"
                self.output?.text = message
            } else {
                if let list = fileList as? GTLRDrive_FileList {
                    self.fileList = list
                }
                else {
                    print("Error: response is not a file list")
                }
            }
            
            self.updateDisplay()
            
        })
    }
    
    func updateDisplay() {
        updateButtons()
        
        
        if let fileList = fileList, let files = fileList.files {
            if files.count == 0 {
                output?.text = "Folder is empty"
                table?.isHidden = true
            } else {
                table?.isHidden = false
                table?.reloadData()
            }
        }
        else {
            output?.text = ""
           table?.isHidden = true
        }
        
    }
    
    func setupButtons() {
        let segItemsArray = ["Mine", "Shared"]
        let segmentedControl = UISegmentedControl(items: segItemsArray)
        segmentedControl.addTarget(self, action: #selector(mineSharedChanged(_:)), for: .valueChanged)
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        var segmentedControlButtonItem: UIBarButtonItem? = nil

        segmentedControlButtonItem = UIBarButtonItem(customView: segmentedControl)
   
        self.segmentedControlButtonItem = segmentedControlButtonItem
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        
        upItem = UIBarButtonItem(title: "Up", style: .plain, target: self, action: #selector(up(_:)))
        
        
        
        navigationItem.setLeftBarButton(doneItem, animated: true)
    }
    
    func updateButtons() {
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if folderTrail.count > 1 && !showShared {
            toolbar?.setItems([upItem, flex, segmentedControlButtonItem].compactMap { $0 }, animated: true)
        } else {
            toolbar?.setItems([flex, segmentedControlButtonItem], animated: true)
        }
    }
    
    // MARK: searching
    @objc func mineSharedChanged(_ sender: UISegmentedControl?) {
        showShared = sender?.selectedSegmentIndex == 1
        
        getFiles()
    }
    
    @objc func up(_ sender: Any?) {
        if folderTrail.count > 1 {
            folderTrail.removeLast()
            manager.folderId = folderTrail.last ?? "root"
            getFiles()
        }
    }
    
    func openFolder(_ file: GTLRDrive_File?) {
        guard let folderId = file?.identifier else {
            print("Can't open folder with no identifier")
            return
        }
        let currentFolder = folderTrail.last
        
        if (folderId == currentFolder) {
            return
        } else {
            folderTrail.append(folderId)
            manager.folderId = folderId
            getFiles()
        }
    }
    
    // MARK: table
    func file(for indexPath: IndexPath) -> GTLRDrive_File? {
        guard let files = fileList?.files else {
            return nil
        }
        
        if indexPath.row >= files.count {
            return nil
        }
        
        return files[indexPath.row]
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList?.files?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "HSDriveFileViewer"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            
            let iv = cell?.imageView
            iv?.image = blankImage
            
            let async = AsyncImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            async.contentMode = UIView.ContentMode.center
            
            iv?.addSubview(async)
        }
        
        let async = cell?.imageView?.subviews.first as? AsyncImageView
        let file = self.file(for: indexPath)
        
        if file != nil {
            cell?.textLabel?.text = file?.name
            async?.imageURL = URL(string: file?.iconLink ?? "")
        } else {
            cell?.textLabel?.text = nil
            async?.image = nil
        }
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = self.file(for: indexPath)
        if file?.isFolder() == true {
            openFolder(file)
        } else {
            dismiss(animated: true) {
                self.completion?(self.manager, file)
            }
        }
    }
}
