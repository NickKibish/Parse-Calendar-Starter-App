//
//  EventListViewController.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 13.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class EventListTableViewCell: PFTableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var eventDescription: UILabel!
    @IBOutlet var participants: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var date: UILabel!
}

class EventListViewController: PFQueryTableViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkExistingUser()
    }
    
    func checkExistingUser() {
        
    }
}

extension EventListViewController {
    @IBAction func logOut(sender: AnyObject) {
        
    }
}

extension EventListViewController : PFLogInViewControllerDelegate {
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
    }
}

extension EventListViewController : PFSignUpViewControllerDelegate {
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        
    }
}
