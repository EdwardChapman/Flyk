//
//  SignInViewController.swift
//  Flyk
//
//  Created by Edward Chapman on 7/30/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class SignInNavController: UINavigationController, UIViewControllerTransitioningDelegate {
    let signInRootViewController = SignInRootViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.backgroundColor = .flykDarkGrey
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = .flykDarkGrey
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        self.pushViewController(signInRootViewController, animated: false)
        
        
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,source: UIViewController) -> UIPresentationController? {
        return SignInPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

class SignInRootViewController: UIViewController {
    lazy var signInLabel: UILabel = {
        let signInLabel = UILabel()
        signInLabel.text = "Sign in"
        signInLabel.textColor = .white
        //        signInLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //        signInLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        return signInLabel
    }()
    var customMessage: String? {
        didSet {
            signInLabel.text = self.customMessage
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .flykDarkGrey
        self.view.addSubview(signInLabel)
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        signInLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        signInLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -200).isActive = true
        
        let emailSignInView = UIView()
        emailSignInView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailSignInTapped)))
        self.view.addSubview(emailSignInView)
        emailSignInView.backgroundColor = .flykDarkWhite
        emailSignInView.translatesAutoresizingMaskIntoConstraints = false
        emailSignInView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7).isActive = true
         emailSignInView.topAnchor.constraint(equalTo: signInLabel.bottomAnchor, constant: 30).isActive = true
        emailSignInView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        emailSignInView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        emailSignInView.layer.cornerRadius = 45/2
        
        let emailSignInLabel = UILabel()
        emailSignInLabel.textColor = .black
        emailSignInLabel.text = "Sign in with Email"
        emailSignInView.addSubview(emailSignInLabel)
        emailSignInLabel.translatesAutoresizingMaskIntoConstraints = false
        emailSignInLabel.centerXAnchor.constraint(equalTo: emailSignInView.centerXAnchor).isActive = true
        emailSignInLabel.centerYAnchor.constraint(equalTo: emailSignInView.centerYAnchor).isActive = true
       
        let dismissButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeTapped(sender:forEvent:)))
        
        dismissButton.title = "Close"
        
        self.navigationItem.leftBarButtonItem = dismissButton
        
    }

    
    @objc func emailSignInTapped(tapGesture: UITapGestureRecognizer){
        print("PUSH EMAIL SIGNIN")
        self.navigationController!.pushViewController(EmailSignInViewController(), animated: true)
    }

    @objc func closeTapped(sender: UIButton, forEvent event: UIEvent) {
        self.navigationController!.dismiss(animated: true, completion: {})
    }
}



class SignInPresentationController: UIPresentationController {
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    @objc func dismiss(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
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
