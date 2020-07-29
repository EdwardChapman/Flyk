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
    let notificationList: [String] = [
        "Bob liked your video",
        "Jeff followed you",
        "Your video reached 100 likes and this line should hopefully spill over this will go to a third line and maybe this will go to a fourth",
        "You reached 100 followers",
        "Smith liked your video",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "Bob liked your video",
        "Jeff followed you",
        "Your video reached 100 likes and this line should hopefully spill over this will go to a third line and maybe this will go to a fourth",
        "You reached 100 followers",
        "Smith liked your video",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "Bob liked your video",
        "Jeff followed you",
        "Your video reached 100 likes and this line should hopefully spill over this will go to a third line and maybe this will go to a fourth",
        "You reached 100 followers",
        "Smith liked your video",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "Bob liked your video",
        "Jeff followed you",
        "Your video reached 100 likes and this line should hopefully spill over this will go to a third line and maybe this will go to a fourth",
        "You reached 100 followers",
        "Smith liked your video",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
    ]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let notificationCellId = "notificationCell"
    
    // don't forget to hook this up from the storyboard
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    
    let dragOverlayView = UIView()
    
    let commentInputView = UIView()
    var commentInputViewBottomAnchor: NSLayoutConstraint!
    
    var keyboardHeight: CGFloat? {
        didSet {
            if let keyboardHeight = self.keyboardHeight {
                print("CONSTANT SET FROM KEYBOARD")
                commentInputViewBottomAnchor.constant = -(keyboardHeight - self.view.safeAreaInsets.bottom)
            }else{
                print("CONSTANT SET TO ZERO")
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
        tableView.backgroundColor = .flykDarkGrey
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(NoticationCell.self, forCellReuseIdentifier: notificationCellId)
        
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
        
        let commentTextField = UITextView()
        commentTextField.text = "Comment..."
        commentTextField.textColor = .white
        commentInputView.addSubview(commentTextField)
        commentTextField.backgroundColor = .black
        
//        commentTextField.layer.borderWidth = 1
//        commentTextField.layer.borderColor = UIColor.flykDarkWhite.cgColor
        commentTextField.layer.cornerRadius = 45/2
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
    
    deinit {
        removeKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.keyboardHeight = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(self.commentInputViewBottomAnchor.constant)
        self.view.layoutIfNeeded()
    }
    override func viewDidAppear(_ animated: Bool) {
       self.keyboardHeight = nil
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.keyboardHeight = nil
    }
    
    @objc fileprivate func keyboardWillShow(notification:NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("KEYBOARD WILL SHOW")
            self.keyboardHeight = keyboardRectValue.height
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        print("HIDE")
        self.keyboardHeight = nil
    }
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        return self.notificationList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = (self.tableView.dequeueReusableCell(withIdentifier: notificationCellId) as! NoticationCell?)!
        
        // set the text from the data model
        //        cell.backgroundColor = .flykDarkGrey
        cell.notificationLabel.text = self.notificationList[indexPath.row]
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
        
//            if shouldDismiss {
//                dragOverlayView.frame.origin = self.view.bounds.origin
//            }else{
//                dragOverlayView.frame.origin = .zero
//            }
//        }
//        isDismissingDrag = false
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
        print(velocity.y)
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
