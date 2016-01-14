//
//  PFUser+Facebook.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 13.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import Foundation
import Parse
import ParseFacebookUtilsV4

extension PFUser {
    func loadFBData() {
        // 3
        if let request = FBSDKGraphRequest(graphPath: "me", parameters: nil) {
            request.startWithCompletionHandler { (connectin, result, error) -> Void in
                if let error = error  {
                    print("Can't load user's data: \(error.localizedDescription)")
                    return
                }
                if let name = result["name"] as? String {
                    self.username = name
                    self.saveInBackground()
                }
            }
        }
        // 3! - EventListViewController
    }
    
    func loadImage(completion: (UIImage?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let imageFile = self["avatar"] as? PFFile
            if imageFile == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(nil)
                })
                return
            }
            let url = imageFile!.url
            if url == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(nil)
                })
                return
            }
            var image: UIImage?
            if let data = NSData(contentsOfURL: NSURL(string: url!)!) {
                image = UIImage(data: data)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(image)
            })
        }
    }
}