//
//  PrevViewController.swift
//  Emotraction
//
//  Created by 김도연 on 2021/11/27.
//

import UIKit
import FirebaseAuth

class PrevViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //선택한 버튼에 따라 유저A, 유저B로 로그인함
    @IBAction func login(_ sender: UIButton) {
        var email = ""
        let password = "appuser"
        
        if sender.tag == 100 {
            email = "usera@gmail.com"
        } else {
            email = "userb@gmail.com"
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "ChatSegue", sender: self)
            }
        }
    }
}

