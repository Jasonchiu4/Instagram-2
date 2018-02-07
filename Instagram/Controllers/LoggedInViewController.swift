//
//  LoggedInViewController.swift
//  Instagram
//
//  Created by Anubhav Saxena on 2/6/18.
//  Copyright © 2018 Anubhav Saxena. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PostCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var anImageView :PFImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    var post: PFObject! {
        didSet {
            self.usernameLabel.text = post["author"] as? String
            self.dateLabel.text = "\(post.createdAt!)"
            self.anImageView.file = post["media"] as? PFFile
            self.captionLabel.text = post["caption"] as? String
            self.anImageView.loadInBackground()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class LoggedInViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    var posts: [PFObject]?
    
    let vc = UIImagePickerController()
    
    @IBAction func onLogout(_ sender: Any) {
        print("Logout")
        PFUser.logOut()
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let query = PFQuery(className: "Post")
        query.order(byDescending: "createdAt")
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.posts = posts
                self.tableView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let posts = posts {
            return posts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        if posts != nil{
            let post = posts?[indexPath.row]
            cell.post = post
            cell.usernameLabel.text = "Anubhav Saxena"
            cell.anImageView.layer.borderWidth = 5
            cell.anImageView.layer.borderColor = UIColor.white.cgColor
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "Instagram_logo.svg")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var query = PFQuery(className: "Post")
        query.order(byDescending: "createdAt")
        query.includeKey("author")
        query.limit = 20
        
        // fetch data asynchronously
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                // do something with the array of object returned by the call
                self.posts = posts
                self.tableView.reloadData()
                print(self.posts)
            } else {
                print(error?.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        var url = URLRequest(url: ("https://tscgram.herokuapp.com/parse" as? URL)!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
}
