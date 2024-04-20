//
//  LoginViewController.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    private var loginViewModel = LoginViewModel1()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginViewModel.delegate = self
    }
    
    // MARK: - Login button tapped
    @IBAction func didTapOnLoginButton(_ sender: Any) {
        
        let request = LoginRequest1(userEmail: userName.text, userPassword: password.text)
       //loginViewModel.loginUser(loginRequest: request)
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    
    //}
}
