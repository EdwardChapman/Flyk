//
//  EditProfileVC.swift
//  Flyk
//
//  Created by Edward Chapman on 8/23/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit


/////////////////////////////////////////////////////////////////////////////////////////////////
// NavController ////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class EditProfileNavController: UINavigationController, UIViewControllerTransitioningDelegate {
    let editProfileRootVC = EditProfileVC()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.backgroundColor = .flykDarkGrey
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = .flykDarkGrey
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        self.pushViewController(editProfileRootVC, animated: false)
        
        
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,source: UIViewController) -> UIPresentationController? {
        return EditProfilePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}





/////////////////////////////////////////////////////////////////////////////////////////////////
// EditProfileVC ////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    lazy var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var newImgToUpload: UIImage? {
        didSet {
            profileImgView.image = self.newImgToUpload
        }
    }

    let profileImgView: UIImageView = {
        let imgV = UIImageView()
        imgV.clipsToBounds = true
        imgV.backgroundColor = UIColor.flykLightDarkGrey
        let l = UILabel()
        imgV.addSubview(l)
        l.text = "Edit"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 17)
        l.backgroundColor = UIColor.flykDarkGrey
        l.alpha = 0.8
        l.textAlignment = .center
        
        l.translatesAutoresizingMaskIntoConstraints = false
        l.bottomAnchor.constraint(equalTo: imgV.bottomAnchor).isActive = true
        l.widthAnchor.constraint(equalTo: imgV.widthAnchor).isActive = true
        l.centerXAnchor.constraint(equalTo: imgV.centerXAnchor).isActive = true
        l.heightAnchor.constraint(equalToConstant: 33).isActive = true
        return imgV
        
    }()
    
    let usernameTopLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.flykDarkWhite
        l.font = UIFont.systemFont(ofSize: 14)
        l.text = "Username"
        return l
    }()
    lazy var usernameTextField: UITextField = {
        let l = UITextField()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 17)
//        l.backgroundColor = UIColor.black
        l.layer.cornerRadius = 8
        l.keyboardAppearance = UIKeyboardAppearance.dark
        l.returnKeyType = UIReturnKeyType.done
        l.delegate = self
        return l
    }()
    
    let bioTopLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.flykDarkWhite
        l.font = UIFont.systemFont(ofSize: 14)
        l.text = "Bio"
        return l
    }()
    lazy var bioTextView: UITextView = {
        let l = UITextView()
        l.textColor = .white
        l.backgroundColor = .clear
        l.font = UIFont.systemFont(ofSize: 15)
        //        l.backgroundColor = UIColor.black
//        l.layer.cornerRadius = 8
        l.keyboardAppearance = UIKeyboardAppearance.dark
        l.translatesAutoresizingMaskIntoConstraints = false
        self.bioTextViewHeightAnchor = l.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        self.bioTextViewHeightAnchor.isActive = true
        self.bioTextViewHeightAnchor.priority = UILayoutPriority(999)
        l.delegate = self
        return l
    }()
    
    weak var myProfileVC: MyProfileVC?
    
    let scrolly = UIScrollView()
    
    var bioTextViewHeightAnchor: NSLayoutConstraint!
    
    @objc func handleMainViewDismissTap(tapGesture: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    
    var scrollyBottomAnchor: NSLayoutConstraint!
    
    var keyboardHeight: CGFloat? {
        didSet {
            if let keyboardHeight = self.keyboardHeight {
                scrollyBottomAnchor.constant = -(keyboardHeight)
            }else{
                scrollyBottomAnchor.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc fileprivate func keyboardWillShow(notification:NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardRectValue.height
            print("KEYBOARD WILL Show")
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        print("KEYBOARD WILL HIDE")
        self.keyboardHeight = nil
    }
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardObserver(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    lazy var errorLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 5
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = .red
        self.view.addSubview(l)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.leadingAnchor.constraint(equalTo: self.profileImgView.trailingAnchor, constant: 8).isActive = true
        l.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8).isActive = true
        l.topAnchor.constraint(equalTo: self.profileImgView.topAnchor).isActive = true
        l.bottomAnchor.constraint(equalTo: self.profileImgView.bottomAnchor).isActive = true
        return l
    }()
    
    var inputErrs: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                var errText = ""
                for err in self.inputErrs {
                    errText.append(err + "\n")
                }
                self.errorLabel.text = errText
            }
        }
    }
    
    @objc func handleSaveButtonTapped(sender: UIButton, forEvent event: UIEvent) {
        inputErrs = []
        // Send Profile Data...
        // if 200 then check if imgToUploadExists and send it
        // Dismiss vc without waiting for img response...
        // reload the profile at some point
        sender.isEnabled = false
        
        let url = URL(string: FlykConfig.mainEndpoint + "/myProfile/update")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: NSDictionary = ["username": self.usernameTextField.text, "bio": self.bioTextView.text]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch let error {
            print(error.localizedDescription)
            sender.isEnabled = true
            return;
        }
        
        
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {sender.isEnabled = true }
            if(error != nil) {return print(error)}
            guard let response = response as? HTTPURLResponse
                else{print("resopnse is not httpurlResponse"); return;}
            print("Status: ", response.statusCode)
            
            if response.statusCode == 200 {
                if let newImg = self.newImgToUpload {
                    self.sendProfilePicToServer(newImg: newImg)
                } else {
                    DispatchQueue.main.async {
                        self.myProfileVC?.fetchMyProfileData()
                    }
                }
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: {})
                }
            }
                
            else if response.statusCode == 409 { //USERNAME CONFLICT
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                self.inputErrs = ["Username already exists"]
                generator.notificationOccurred(.error)
            }
            
            else if response.statusCode == 500 {
                print("Server Error")
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                self.inputErrs = ["Server Error"]
                generator.notificationOccurred(.error)
            }
            
            
            
            else if response.statusCode == 400 {
                print("Client Error")
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                guard let mime = response.mimeType, mime == "application/json" else {
                    print("Wrong MIME type!")
                    return
                }
                
                do {
                    let json : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    print(json["errors"])
                    if let errors = json["errors"] as? [String] {
                        self.inputErrs = errors
                    }
                    
                } catch let err {
                    print("JSON error: \(err.localizedDescription)")
                }
                generator.notificationOccurred(.error)
            }
        }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMainViewDismissTap)))
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCloseButtonTapped))
        cancelButton.tintColor = .flykDarkWhite
//        dismissButton.title = "Cancel"
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSaveButtonTapped))
        saveButton.tintColor = .flykBlue
        //        dismissButton.title = "Cancel"
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.view.addSubview(scrolly)
        scrolly.translatesAutoresizingMaskIntoConstraints = false
        scrolly.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrolly.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollyBottomAnchor = scrolly.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        scrollyBottomAnchor.isActive = true
        scrolly.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        let contentView = UIView()
        scrolly.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrolly.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrolly.bottomAnchor).isActive = true
        
        
        let leftInset: CGFloat = 17
        let rightInset: CGFloat = -17
        
        self.view.backgroundColor = .flykDarkGrey
        
//        let closeButton = UIButton(type: .system)
//        self.view.addSubview(closeButton)
//        closeButton.setTitle("Close", for: .normal)
//        closeButton.setTitleColor(.flykDarkWhite, for: .normal)
//        closeButton.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12).isActive = true
//        closeButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        contentView.addSubview(profileImgView)
        profileImgView.translatesAutoresizingMaskIntoConstraints = false
        profileImgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25).isActive = true
        profileImgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftInset).isActive = true
        profileImgView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImgView.heightAnchor.constraint(equalTo: profileImgView.widthAnchor).isActive = true
        profileImgView.layer.cornerRadius = 50
        profileImgView.isUserInteractionEnabled = true
        profileImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImgTap)))
        
        
        contentView.addSubview(self.usernameTopLabel)
        self.usernameTopLabel.translatesAutoresizingMaskIntoConstraints = false
        self.usernameTopLabel.leadingAnchor.constraint(equalTo: profileImgView.leadingAnchor).isActive = true
        self.usernameTopLabel.topAnchor.constraint(equalTo: profileImgView.bottomAnchor, constant: 30).isActive = true
        self.usernameTopLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: rightInset).isActive = true
        
        contentView.addSubview(self.usernameTextField)
        self.usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.usernameTextField.leadingAnchor.constraint(equalTo: self.usernameTopLabel.leadingAnchor).isActive = true
        self.usernameTextField.topAnchor.constraint(equalTo: self.usernameTopLabel.bottomAnchor, constant: 10).isActive = true
        self.usernameTextField.trailingAnchor.constraint(equalTo: self.usernameTopLabel.trailingAnchor).isActive = true
        
        
        let utfBottomBorder = UIView()
        utfBottomBorder.alpha = 0.8
        contentView.addSubview(utfBottomBorder)
        utfBottomBorder.backgroundColor = .flykDarkWhite
        utfBottomBorder.translatesAutoresizingMaskIntoConstraints = false
        utfBottomBorder.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor, constant: 0).isActive = true
        utfBottomBorder.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor, constant: 0).isActive = true
        utfBottomBorder.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 0).isActive = true
        utfBottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
        contentView.addSubview(bioTopLabel)
        bioTopLabel.translatesAutoresizingMaskIntoConstraints = false
        bioTopLabel.leadingAnchor.constraint(equalTo: usernameTopLabel.leadingAnchor).isActive = true
        bioTopLabel.trailingAnchor.constraint(equalTo: usernameTopLabel.trailingAnchor).isActive = true
        bioTopLabel.topAnchor.constraint(equalTo: utfBottomBorder.bottomAnchor, constant: 20).isActive = true
        
        contentView.addSubview(bioTextView)
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.topAnchor.constraint(equalTo: bioTopLabel.bottomAnchor, constant: 10).isActive = true
        bioTextView.leadingAnchor.constraint(equalTo: usernameTopLabel.leadingAnchor).isActive = true
        bioTextView.trailingAnchor.constraint(equalTo: usernameTopLabel.trailingAnchor).isActive = true
        
        bioTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 34).isActive = true
        
        
        let btvBottomBorder = UIView()
        btvBottomBorder.alpha = 0.8
        contentView.addSubview(btvBottomBorder)
        btvBottomBorder.backgroundColor = .flykDarkWhite
        btvBottomBorder.translatesAutoresizingMaskIntoConstraints = false
        btvBottomBorder.leadingAnchor.constraint(equalTo: bioTextView.leadingAnchor, constant: 0).isActive = true
        btvBottomBorder.trailingAnchor.constraint(equalTo: bioTextView.trailingAnchor, constant: 0).isActive = true
        btvBottomBorder.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 0).isActive = true
        btvBottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true

        //THE LAST VIEW MUST BE SET TO CONTETNVIEW HEIGHT......
        
        contentView.subviews.last!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        addKeyboardObserver()
        
        self.view.layoutIfNeeded()
        self.loadDataFromProfile()
    }
    
    deinit {
        removeKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func loadDataFromProfile() {
        if let currentProfileData = self.myProfileVC?.currentProfileData {
            if let profile_img_filename = currentProfileData["profile_img_filename"] as? String {
                //TODO: this
                let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profile/photo/"+profile_img_filename)!
                print("FETCHING PIMG", pImgURL)
                
                URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
                    if let d = data {
                        DispatchQueue.main.async {
                            self.profileImgView.image = UIImage(data: d)
                        }
                    }
                }).resume()
            } else {
                DispatchQueue.main.async {
                    self.profileImgView.image = FlykConfig.defaultProfileImage
                }
            }
            
            if let username = currentProfileData["username"] as? String {
                self.usernameTextField.text = username
                self.usernameTextField.placeholder = username
                
                if let mutAttrPl = usernameTextField.attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString {
                    mutAttrPl.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.flykLightGrey], range: NSRange(location: 0, length: mutAttrPl.length))
                    usernameTextField.attributedPlaceholder = mutAttrPl
                }
            }
            
            if let profile_bio = currentProfileData["profile_bio"] as? String {
                self.bioTextView.text = profile_bio
                self.bioTextViewHeightAnchor.constant = self.bioTextView.contentSize.height
                self.view.layoutIfNeeded()
                
            }
            
        }
    }
    
    
    @objc func handleCloseButtonTapped(sender: UIButton, forEvent event: UIEvent) {
        self.dismiss(animated: true) {
            
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let oldConst = self.bioTextViewHeightAnchor.constant
        self.bioTextViewHeightAnchor.constant = self.bioTextView.contentSize.height
        self.view.layoutIfNeeded()
        
        if oldConst != self.bioTextViewHeightAnchor.constant {
            
            let p = CGPoint(x: 0, y: scrolly.contentSize.height - scrolly.frame.height)
            if p.y > 0 {
                self.scrolly.setContentOffset(p, animated: true)
            }
//            guard let selRange = textView.selectedTextRange else {return}
//            let cursorPosition = textView.caretRect(for: selRange.start)
//            print(cursorPosition.maxY)
//            let convR = scrolly.convert(cursorPosition, from: textView)
//            let difY = scrolly.contentSize.height -
//            scrolly.setContentOffset(convR.origin, animated: true)
//            self.scrolly.scrollRectToVisible(convR, animated: true)
        }
    }
    

    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING FUNCTIONS //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func sendProfilePicToServer(newImg : UIImage) {
        
        
        let endPointURL = FlykConfig.uploadEndpoint+"/upload/profilePhoto"
        
        let dataOpt: Data? = newImg.jpegData(compressionQuality: 1)
        guard let dataNotConverted = dataOpt else { return }
        let data = NSData(data: dataNotConverted)
        
        
        let boundary = "?????"
        var request = URLRequest(url: URL(string: endPointURL)!)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.httpBody = MultiPartPost_2.photoDataToFormData(data: data, boundary: boundary, fileName: "profilePhoto") as Data
        request.addValue("multipart/form-data;boundary=\"" + boundary+"\"",
                         forHTTPHeaderField: "Content-Type")
        request.addValue("image/jpeg", forHTTPHeaderField: "mimeType")
        request.addValue(String((request.httpBody! as NSData).length), forHTTPHeaderField: "Content-Length")
        
        request.addValue("text/plain", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //            print(data, response)
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                print("Server error!")
                //                    print(data, response, error)
                return
            }
            DispatchQueue.main.async {
                self.myProfileVC?.fetchMyProfileData()
            }
            print("SUCCESS")
        }
        
        print("Upload Started")
        task.resume()
        
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    // UIImagePickerControllerDelegate //////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////
    @objc func handleProfileImgTap(tapGesture: UITapGestureRecognizer) {
        if !appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign in to create a profile photo") {
            return
        }
        let profileImgActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        profileImgActionSheet.addAction(UIAlertAction(title: "Remove Current Image", style: .destructive, handler:
            { _ in
                // Delete current image
                
        }
        ))
        profileImgActionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler:
            {_ in
                // popCamera taking view
                self.imgFromCamera()
        }
        ))
        profileImgActionSheet.addAction(UIAlertAction(title: "Choose From Photos", style: .default, handler:
            { _ in
                // pop photo library
                self.imgFromPhotos()
        }
        ))
        profileImgActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:
            { _ in
                //closes the action sheet.
        }
        ))
        
        self.present(profileImgActionSheet, animated: true, completion: nil)
    }
    
    func imgFromCamera() {
        let myPickerController = UIImagePickerController()
        myPickerController.allowsEditing = true
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.camera
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func imgFromPhotos() {
        
        let myPickerController = UIImagePickerController()
        myPickerController.allowsEditing = true
        //        myPickerController.preferredContentSize = CGSize(width: 100, height: 100)
        
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.newImgToUpload = img
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}





/////////////////////////////////////////////////////////////////////////////////////////////////
// PresentationController ///////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class EditProfilePresentationController: UIPresentationController {
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
//    @objc func dismiss(){
//        self.presentedViewController.dismiss(animated: true, completion: nil)
//    }
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    override var frameOfPresentedViewInContainerView: CGRect{
        let vcHeight =  self.containerView!.frame.height/1.1
        let newY = self.containerView!.frame.height-vcHeight
        return CGRect(origin: CGPoint(x: 0, y: newY), size: CGSize(width: self.containerView!.frame.width, height: vcHeight))
    }
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }
    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            
        })
    }
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.layer.masksToBounds = true
        presentedView!.layer.cornerRadius = 10
    }
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
}
