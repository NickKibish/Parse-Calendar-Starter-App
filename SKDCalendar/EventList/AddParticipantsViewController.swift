//
//  AddParticipantsViewController.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 13.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import UIKit
import Parse

let UserCellID = "AddParticipantsTableViewCell"
protocol AddParticipantsDelegate {
    func userSelected(users:[PFUser])
}

class AddParticipantsTableViewCell: UITableViewCell {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var userName: UILabel!
}

class AddParticipantsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var delegate: AddParticipantsDelegate?
    
    var selectedUsers: [PFUser] = [PFUser.currentUser()!]
    var unselectedUsers: [PFUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
    }
    
    func loadUsers() {
        //5
        unselectedUsers.removeAll()
        let query = PFUser.query()
        let userIds = selectedUsers.map { (user) -> String in
            return user.objectId!
        }
        if searchBar.text?.characters.count > 0 {
            query?.whereKey("username", containsString: searchBar.text)
        }
        query?.whereKey("objectId", notContainedIn: userIds)
        query?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if error != nil {
                print("Can't load users: \(error)")
            }
            if let users = result as? [PFUser] {
                self.unselectedUsers = users
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        })
        //5!
    }
}

extension AddParticipantsViewController {
    @IBAction func done(sender: AnyObject) {
        delegate?.userSelected(selectedUsers)
        navigationController?.popViewControllerAnimated(true)
    }
}

extension AddParticipantsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Participants" : "Invite People"
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
        
        let user = unselectedUsers[indexPath.row]
        unselectedUsers.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        selectedUsers.append(user)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: selectedUsers.count - 1, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension AddParticipantsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selectedUsers.count
        } else {
            return unselectedUsers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(UserCellID) as? AddParticipantsTableViewCell
        if cell == nil {
            cell = AddParticipantsTableViewCell(style: .Default, reuseIdentifier: UserCellID)
        }
        
        var users: [PFUser]?
        if indexPath.section == 0 {
            users = selectedUsers
        } else {
            users = unselectedUsers
        }
        
        let user = users![indexPath.row]
        cell?.userName.text = user.username
        
        cell?.avatar.image = UIImage(named: "noavatar")
        user.loadImage { (image) -> Void in
            if image != nil {
                cell?.avatar.image = image
            }
        }
        
        cell?.avatar.layer.cornerRadius = 35
        cell?.avatar.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell?.avatar.layer.borderWidth = 0.5
        
        return cell!
    }
}

extension AddParticipantsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        loadUsers()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadUsers()
    }
}