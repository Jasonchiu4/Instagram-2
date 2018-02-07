//
//  PhotoViewController.swift
//  Instagram
//
//  Created by Anubhav Saxena on 2/7/18.
//  Copyright © 2018 Anubhav Saxena. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!

    @IBAction func onCancel(_ sender: Any) {
        performSegue(withIdentifier: "backtohomeSegue", sender: nil)
    }
    
    @IBAction func onSelectPhoto(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func sharePost(_ sender: Any) {
        let image = imageView.image
        let caption = captionField.text
        
        Post.postUserImage(image: image, withCaption: caption, withCompletion: { (success: Bool, error: Error?) in
            if(success == true) {
                
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "backtohomeSegue", sender: nil)
                
            } else {
                let errorAlertController = UIAlertController(title: "Upload Failed", message: "An error occured. Please try again.", preferredStyle: .alert)
                let errorAction = UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                })
                errorAlertController.addAction(errorAction)
                self.present(errorAlertController, animated: true)
            }
        })
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let size = CGSize(width: 288, height: 288)
        imageView.image = resize(image: editedImage, newSize: size)
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.white.cgColor
        dismiss(animated: true, completion: nil)
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
