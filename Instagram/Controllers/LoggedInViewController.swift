//
//  LoggedInViewController.swift
//  Instagram
//
//  Created by Anubhav Saxena on 2/6/18.
//  Copyright © 2018 Anubhav Saxena. All rights reserved.
//

import UIKit
import Parse

class Post: PFObject, PFSubclassing {
    @NSManaged var media : PFFile
    @NSManaged var author: String?
    
    class func parseClassName() -> String {
        return "Post"
    }
    
    class func postUserImage(image: UIImage?, withCompletion completion: PFBooleanResultBlock?) {
        // use subclass approach
        let post = Post()
        
        // Add relevant fields to the object
        post.media = getPFFileFromImage(image: image)!
        post.author = PFUser.current()?.username
        
        // Save object (following function will save the object in Parse asynchronously)
        post.saveInBackground(block: completion)
    }
    
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
}

class PostCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mediaLabel: UIImageView!
}



var allPosts: [PFObject]?

class LoggedInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var postTableView: UITableView!
    
    let vc = UIImagePickerController()
    
    @IBAction func onLogout(_ sender: Any) {
        print("Logout")
        PFUser.logOut()
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    func fetchContent() {
        var query = Post.query()
        query?.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                // do something with the array of object returned by the call
                allPosts = posts
                print(allPosts)
                self.postTableView.reloadData();
            } else {
                print(error?.localizedDescription)
                print("FAIILED FETCH")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allPosts = allPosts {
            return allPosts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = postTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let currPost = allPosts?[indexPath.row] as! Post
        postCell.selectionStyle = .none
        // Crashes app
        //postCell.usernameLabel.text = currPost.author
        //print(currPost.author)
        //postCell.mediaLabel.image = currPost.media as! UIImageView
        return postCell
    }
    
    @IBAction func onUpload(_ sender: Any) {
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        Post.postUserImage(image: editedImage, withCompletion: nil)
        print("Image sending!!")
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
        print("Image posted!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.dataSource = self
        postTableView.delegate = self
        fetchContent()
        vc.delegate = self
        //For selecting image
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
