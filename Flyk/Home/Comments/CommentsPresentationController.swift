//
//  CommentsPresentationController.swift
//  Flyk
//
//  Created by Edward Chapman on 7/27/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class CommentsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    

    
    // Data model: These strings will be the data for the table view cells
    var commentList: [NSDictionary] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var currentVideoId: String?
    
    func setupComments(forVideo videoId: String?){
        //CLEAR CURRENT COMMENT LIST
        //SET CONTENT OFFSET TO ZERO
        //Fetch Comments for new videoId
        if videoId != currentVideoId {
            commentList = []
            currentVideoId = videoId
            fetchComments()
        }
    }
    
    var goToProfileFunction: ((UITapGestureRecognizer)->())?
    @objc func handleCellProfileImgTap(tapGesture: UITapGestureRecognizer){
        if let goToProfileFunction = self.goToProfileFunction {
            goToProfileFunction(tapGesture)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING //////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func fetchComments(){
        if let videoId = currentVideoId {
            
            let url = URL(string: FlykConfig.mainEndpoint + "/video/comments")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let parameters: NSDictionary = ["videoId": videoId]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch let error {
                print(error.localizedDescription)
                return;
            }
            
            
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if(error != nil) {return print(error)}
                guard let response = response as? HTTPURLResponse
                    else{print("resopnse is not httpurlResponse"); return;}
//                print("Status: ", response.statusCode)
                
                if response.statusCode == 200 {
                    do {
                        let json : [NSDictionary] = try JSONSerialization.jsonObject(with: data!, options: []) as! [NSDictionary]
                        
                        self.commentList = json
                    } catch let err {
                        print("JSON error: \(err.localizedDescription)")
                    }
                }
                
                if response.statusCode == 500 {
                    print("Server Error")
//                    self.inputErrs = ["Server Error"]
                    //PRINT OUT THE RESPONSE HERE
                    // ??? maybey a warning lol
                }
                
                if response.statusCode == 400 {
                    print("Client Error")

                }
            }.resume()
        }
    }
    
    
    // cell reuse id (cells that scroll out of view can be reused)
    let commentCellId = "commentCell"
    
    // don't forget to hook this up from the storyboard
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    
    let dragOverlayView = UIView()
    
    let commentInputView = UIView()
    let commentTextField = UITextView()
    var commentInputViewBottomAnchor: NSLayoutConstraint!
    
    var keyboardHeight: CGFloat? {
        didSet {
            if let keyboardHeight = self.keyboardHeight {
                commentInputViewBottomAnchor.constant = -(keyboardHeight - self.view.safeAreaInsets.bottom)
            }else{
                commentInputViewBottomAnchor.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(dragOverlayView)
        dragOverlayView.translatesAutoresizingMaskIntoConstraints = false
        dragOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        dragOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        dragOverlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        dragOverlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        dragOverlayView.backgroundColor = .flykDarkGrey
        
        // Register the table view cell class and its reuse id
        
        dragOverlayView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .flykDarkGrey
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(CommentsTableViewCell.self, forCellReuseIdentifier: commentCellId)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        
        
        dragOverlayView.addSubview(commentInputView)
//        commentInputView.backgroundColor = .white
        commentInputView.translatesAutoresizingMaskIntoConstraints = false
        commentInputView.leadingAnchor.constraint(equalTo: dragOverlayView.leadingAnchor).isActive = true
        commentInputView.trailingAnchor.constraint(equalTo: dragOverlayView.trailingAnchor).isActive = true
        commentInputView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        commentInputViewBottomAnchor = commentInputView.bottomAnchor.constraint(equalTo: dragOverlayView.safeAreaLayoutGuide.bottomAnchor)
        commentInputViewBottomAnchor.isActive = true
        
        
        commentTextField.text = "Comment..."
        commentTextField.textColor = .white
        commentInputView.addSubview(commentTextField)
        commentTextField.backgroundColor = .black
        commentTextField.font = UIFont.systemFont(ofSize: 18)
        commentTextField.layer.cornerRadius = 45/2
        commentTextField.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 45)
        self.view.layoutIfNeeded()
        
        let profileImgView = UIImageView(image: UIImage())
        commentInputView.addSubview(profileImgView)
        profileImgView.backgroundColor = .flykLoadingGrey
        profileImgView.translatesAutoresizingMaskIntoConstraints = false
        profileImgView.leadingAnchor.constraint(equalTo: commentInputView.leadingAnchor, constant: 10).isActive = true
        profileImgView.bottomAnchor.constraint(equalTo: commentInputView.bottomAnchor, constant: -5).isActive = true
        profileImgView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        profileImgView.heightAnchor.constraint(equalTo: profileImgView.widthAnchor).isActive = true
        profileImgView.layer.cornerRadius = 35/2
        
        
        
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        commentTextField.leadingAnchor.constraint(equalTo: profileImgView.trailingAnchor, constant: 10).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: commentInputView.trailingAnchor, constant: -10).isActive = true
        commentTextField.bottomAnchor.constraint(equalTo: commentInputView.bottomAnchor, constant: 0).isActive = true
        commentTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 45).isActive = true
        
        let sendComment = UIImageView(image: UIImage(named: "lessPointyArrowBlue"))
        sendComment.isUserInteractionEnabled = true
        sendComment.contentMode = .scaleAspectFit
        commentInputView.addSubview(sendComment)
        sendComment.translatesAutoresizingMaskIntoConstraints = false
        sendComment.trailingAnchor.constraint(equalTo: commentTextField.trailingAnchor, constant: -4).isActive = true
        sendComment.bottomAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: -7.5).isActive = true
        sendComment.heightAnchor.constraint(equalToConstant: 30).isActive = true
        sendComment.widthAnchor.constraint(equalTo: sendComment.heightAnchor).isActive = true
        sendComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendCommentTap(tapGesture:))))
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: dragOverlayView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: dragOverlayView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: dragOverlayView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: commentInputView.topAnchor).isActive = true
        
//        tableView.refreshControl = UIRefreshControl()
//        tableView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        //        tableView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        //        tableView.refreshControl!.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 10).isActive = true
        //        tableView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        addKeyboardObserver()
        
        
    }
    
    @objc func handleSendCommentTap(tapGesture: UITapGestureRecognizer){
        self.commentTextField.resignFirstResponder()
        if let videoId = self.currentVideoId {
            if let commentText = commentTextField.text {
                let trimmedComment = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedComment.count > 0 {
                    //DO THE POST REQUEST HERE
                    
                    let url = URL(string: FlykConfig.mainEndpoint + "/video/comments/post")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    
                    
                    do {
                        let parameters: NSDictionary = ["videoId": videoId, "comment": trimmedComment]
                        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                    } catch let error {
                        print(error.localizedDescription)
                        return;
                    }
                    
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if(error != nil) {return print(error)}
                        guard let response = response as? HTTPURLResponse
                            else{print("resopnse is not httpurlResponse"); return;}
                                        print("Status: ", response.statusCode)
                        self.fetchComments()
                        if response.statusCode == 200 {
                            
                        }
                        
                        if response.statusCode == 500 {
                            print("Server Error")
                            //                    self.inputErrs = ["Server Error"]
                            //PRINT OUT THE RESPONSE HERE
                            // ??? maybey a warning lol
                        }
                        
                        if response.statusCode == 400 {
                            print("Client Error")

                        }
                        }.resume()
                    
                }
            }
        }
        
        self.commentTextField.text = ""
        //Show placeholder label here
    }
    
    
    deinit {
        removeKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardHeight = nil
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.keyboardHeight = nil
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
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        //        fetchVideoList()
        // Dismiss the refresh control.
        DispatchQueue.main.async { self.tableView.refreshControl!.endRefreshing() }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = (self.tableView.dequeueReusableCell(withIdentifier: commentCellId) as! CommentsTableViewCell?)!
        
        // set the text from the data model
        //        cell.backgroundColor = .flykDarkGrey
        cell.commentLabel.text = self.commentList[indexPath.row]["comment_text"] as? String
        if let pImgFilename = self.commentList[indexPath.row]["profile_img_filename"] as? String {
            let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profile/photo/"+pImgFilename)!
            URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    cell.contextProfileImg.image = UIImage(data: data!)
                }
            }).resume()
        }
        if let goToProfileFunc = self.goToProfileFunction {
            let gestReq = UITapGestureRecognizer(target: self, action: #selector(handleCellProfileImgTap(tapGesture:)))
            cell.contextProfileImg.addGestureRecognizer(gestReq)
        }
        
        //        cell.textLabel?.textColor = .white
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // UIViewControllerTransitioningDelegate ////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,source: UIViewController) -> UIPresentationController? {
        return CommentsPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // SCROLLVIEW DELEGATE //////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////
    var shouldDismiss = false
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.shouldDismiss {
            self.dismiss(animated: true, completion: {self.dragOverlayView.frame.origin = .zero})
        }else{
            UIView.animate(withDuration: 0.2) {
            self.dragOverlayView.frame.origin = .zero
            }
        }
        isDismissingDrag = false
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isCurDragging = false
//        targetContentOffset.pointee.y
        if velocity.y < -1 && scrollView.contentOffset.y <= 0{
            shouldDismiss = true
        } else {
            shouldDismiss = false
        }
    }
    var isCurDragging = false
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isCurDragging = true
    }
    var isDismissingDrag = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // if dismissing it will handle itself...
        // we need to handle when it isn't a dismisisng
        if(scrollView.contentOffset.y < 0 && (isCurDragging)){
            isDismissingDrag = true
            dragOverlayView.center.y -= scrollView.contentOffset.y
            if dragOverlayView.frame.origin.y < 0 { dragOverlayView.frame.origin = .zero }
            scrollView.contentOffset.y = 0
        }
    }
}











////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CLASS CommentsPresentationController ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CommentsPresentationController: UIPresentationController{
    let blurEffectView: UIView//UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    @objc func dismiss(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIView()//UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    override var frameOfPresentedViewInContainerView: CGRect{
        let vcHeight =  self.containerView!.frame.height/1.4
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height-vcHeight), size: CGSize(width: self.containerView!.frame.width, height: vcHeight))
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
