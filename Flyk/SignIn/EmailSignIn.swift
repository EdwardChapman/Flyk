//
//  EmailSignIn.swift
//  Flyk
//
//  Created by Edward Chapman on 7/31/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit


class EmailSignInViewController: UIViewController, UITextFieldDelegate {
    
    let emailInput = UITextField()
    let passwordInput = UITextField()
    let signInErrorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .flykDarkGrey
        

        
        emailInput.textContentType = .emailAddress
        emailInput.delegate = self
        emailInput.backgroundColor = .black
        emailInput.layer.cornerRadius = 10
        emailInput.clipsToBounds = true
        emailInput.textColor = .white
        emailInput.returnKeyType = .done
        emailInput.keyboardAppearance = .dark
        emailInput.keyboardType = .emailAddress
        self.view.addSubview(emailInput)
        emailInput.translatesAutoresizingMaskIntoConstraints = false
        emailInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        emailInput.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -250).isActive = true
        emailInput.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        emailInput.heightAnchor.constraint(equalToConstant: 35).isActive = true

        let emailInputLabel = UILabel()
        self.view.addSubview(emailInputLabel)
        emailInputLabel.text = "Email"
        emailInputLabel.textColor = .flykDarkWhite
        emailInputLabel.translatesAutoresizingMaskIntoConstraints = false
        emailInputLabel.bottomAnchor.constraint(equalTo: emailInput.topAnchor, constant: -5).isActive = true
        emailInputLabel.leadingAnchor.constraint(equalTo: emailInput.leadingAnchor).isActive = true
        
        
        passwordInput.textContentType = .password
        passwordInput.delegate = self
        passwordInput.backgroundColor = .black
        passwordInput.isSecureTextEntry = true
        passwordInput.returnKeyType = .done
        passwordInput.keyboardAppearance = .dark
        passwordInput.layer.cornerRadius = 10
        passwordInput.clipsToBounds = true
        passwordInput.textColor = .white
        self.view.addSubview(passwordInput)
        passwordInput.translatesAutoresizingMaskIntoConstraints = false
        passwordInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        passwordInput.topAnchor.constraint(equalTo: emailInput.bottomAnchor, constant: 45).isActive = true
        passwordInput.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        passwordInput.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        let passwordInputLabel = UILabel()
        self.view.addSubview(passwordInputLabel)
        passwordInputLabel.text = "Password"
        passwordInputLabel.textColor = .flykDarkWhite
        passwordInputLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordInputLabel.bottomAnchor.constraint(equalTo: passwordInput.topAnchor, constant: -5).isActive = true
        passwordInputLabel.leadingAnchor.constraint(equalTo: passwordInput.leadingAnchor).isActive = true
        
        

        let buttonGap: CGFloat = 5
        let createAccountButton = UIButton(type: .custom)
        createAccountButton.addTarget(self, action: #selector(createAccountTap(sender:forEvent:)), for: .touchUpInside)
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.setTitleColor(.black, for: .normal)
        createAccountButton.layer.cornerRadius = 10
        self.view.addSubview(createAccountButton)
        createAccountButton.backgroundColor = .flykDarkWhite
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.topAnchor.constraint(equalTo: passwordInput.bottomAnchor, constant: 20).isActive = true
        createAccountButton.leadingAnchor.constraint(equalTo: passwordInput.leadingAnchor).isActive = true
        createAccountButton.trailingAnchor.constraint(equalTo: passwordInput.centerXAnchor, constant: -buttonGap).isActive = true
        createAccountButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let signInButton = UIButton(type: .custom)

        signInButton.addTarget(self, action: #selector(signInTap(sender:forEvent:)), for: .touchUpInside)
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.layer.cornerRadius = 10
        self.view.addSubview(signInButton)
        signInButton.backgroundColor = .flykBlue
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.topAnchor.constraint(equalTo: createAccountButton.topAnchor).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: passwordInput.trailingAnchor).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: passwordInput.centerXAnchor, constant: buttonGap).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        signInErrorLabel.textColor = .red
        signInErrorLabel.numberOfLines = 10
        self.view.addSubview(signInErrorLabel)
        signInErrorLabel.lineBreakMode = .byWordWrapping
        signInErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        signInErrorLabel.leadingAnchor.constraint(equalTo: createAccountButton.leadingAnchor).isActive = true
        signInErrorLabel.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor).isActive = true
        signInErrorLabel.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20).isActive = true
//        signInErrorLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
    }
    
    @objc func signInTap(sender: UIButton, forEvent event: UIEvent) {
        guard
            let email = self.emailInput.text,
            let password = self.passwordInput.text
            else{return}
        var inputErrs: [String] = []
        if password.count == 0 {
            inputErrs.append("Empty Password")
        }
        if email.count == 0 {
            inputErrs.append("Empty Email")
        }
        if inputErrs.count > 0 {
            self.signInErrorLabel.text = ""
            for err in inputErrs {
                self.signInErrorLabel.text?.append(err)
                self.signInErrorLabel.text?.append("\n")
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return;
        }
        
    }
    @objc func createAccountTap(sender: UIButton, forEvent event: UIEvent) {
        guard
            let email = self.emailInput.text,
            let password = self.passwordInput.text
        else{return}
        
        var inputErrs: [String] = []
        if password.count == 0 {
            inputErrs.append("Empty Password")
        }
        if email.count == 0 {
            inputErrs.append("Empty Email")
        }
        if inputErrs.count > 0 {
            self.signInErrorLabel.text = ""
            for err in inputErrs {
                self.signInErrorLabel.text?.append(err)
                self.signInErrorLabel.text?.append("\n")
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return;
        }
        let agePickerVc = AgePickerViewController()
        agePickerVc.email = email
        agePickerVc.password = password
        self.navigationController?.pushViewController(agePickerVc, animated: true)
    }
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //TextFieldDelegate//////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if textField === self.emailInput {
            self.passwordInput.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.contains(" ") || string.contains("\t") || string.contains("\n"))
            && textField === self.emailInput {
            return false
        }else{
            return true
        }
    }
}

class AgePickerViewController: UIViewController {
    let agePicker = UIDatePicker()
    var email: String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .flykDarkGrey
        self.view.addSubview(agePicker)
        agePicker.translatesAutoresizingMaskIntoConstraints = false
        agePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        agePicker.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -150).isActive = true
        agePicker.datePickerMode = .date
        agePicker.backgroundColor = .flykDarkWhite
        agePicker.layer.cornerRadius = 20
        agePicker.clipsToBounds = true
        var minDate = DateComponents()
        minDate.calendar = Calendar(identifier: .gregorian)
        minDate.year = 1900
        minDate.day = 1
        minDate.month = 1
        agePicker.minimumDate = minDate.date
        agePicker.maximumDate = Date()
        
        let agePickerTitle = UILabel()
        agePickerTitle.font = agePickerTitle.font.withSize(22)
        agePickerTitle.text = "Please Enter Your Date Of Birth"
        agePickerTitle.textColor = .flykDarkWhite
        self.view.addSubview(agePickerTitle)
        agePickerTitle.translatesAutoresizingMaskIntoConstraints = false
        agePickerTitle.leadingAnchor.constraint(equalTo: agePicker.leadingAnchor).isActive = true
        agePickerTitle.bottomAnchor.constraint(equalTo: agePicker.topAnchor, constant: -15).isActive = true
        
        
        let nextButton = UIButton(type: .custom)
        
        nextButton.addTarget(self, action: #selector(handleNextTap(sender:forEvent:)), for: .touchUpInside)
        nextButton.setTitle("Create Account", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
        self.view.addSubview(nextButton)
        nextButton.backgroundColor = .flykBlue
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.topAnchor.constraint(equalTo: agePicker.bottomAnchor, constant: 15).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: agePicker.trailingAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        
    }
    
    var blockNextTap = false
    @objc func handleNextTap(sender: UIButton, forEvent event: UIEvent) {
        blockNextTap = true
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: agePicker.date)
        
        let sendCreateAccountVC = SendCreateAccountViewController()
        sendCreateAccountVC.dobString = dateString
        sendCreateAccountVC.email = email
        sendCreateAccountVC.password = password
        self.navigationController?.pushViewController(sendCreateAccountVC, animated: true)
        sendCreateAccountVC.createAccountPostReq()
        blockNextTap = false
    }

}


class SendCreateAccountViewController: UIViewController {
    var dobString : String!
    var email : String!
    var password : String!
    
    let blockSpinner = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .flykDarkGrey
        self.view.addSubview(blockSpinner)
        blockSpinner.backgroundColor = .flykBlue
        blockSpinner.translatesAutoresizingMaskIntoConstraints = false
        blockSpinner.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        blockSpinner.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: -50).isActive = true
        blockSpinner.widthAnchor.constraint(equalToConstant: 55).isActive = true
        blockSpinner.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        blockSpinner.layer.cornerRadius = 8
        
        
        
        
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    

    
    func createAccountPostReq(){
        print(
            dobString,
            email,
            password
        );
        
//        @keyframes rollAnimation {
//            0%   { left:-50px; }
//            12.5%  { left:-25px;bottom:8px;transform: rotate(45deg) }
//            25%  { left:0px;bottom:0px;transform: rotate(90deg);}
//            37.5%  { left:25px;bottom: 8px;transform: rotate(135deg) }
//            50%  { left:50px;bottom:0px;transform: rotate(180deg);}
//            62.5%  { left:75px;bottom: 8px;transform: rotate(225deg) }
//            75%  { left:100px;bottom:0px;transform: rotate(270deg);}
//            87.5% { left:125px;bottom:8px;transform: rotate(315deg);}
//            100% { left:150px;bottom:0px;transform: rotate(360deg);}
//        }
        
        UIView.animateKeyframes(withDuration: 4, delay: 0, options: .repeat, animations: {
            
            let circ = 2*CGFloat.pi
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (45/360)*circ)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.125, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (90/360)*circ)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (135/360)*circ)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.375, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (180/360)*circ)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.50, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (225/360)*circ)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.625, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (270/360)*circ)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (315/360)*circ)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.875, relativeDuration: 0.125) {
                self.blockSpinner.transform = self.blockSpinner.transform.rotated(by: (360/360)*circ)
            }
        }) { (finished) in
            
        }
    }
}




