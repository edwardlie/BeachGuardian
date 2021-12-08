
// PhotoViewController.swift
// BeachGuardian

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   var isInitialized = falsea
   @IBOutlet weak var imageView: UIImageView!
   override func viewDidLoad() {
       super.viewDidLoad()
       //create title and done button for picture
       _ = self.view
       navigationItem.title = "Camera"
       navigationItem.rightBarButtonItem = UIBarButtonItem(
           barButtonSystemItem: .done,
           target: self,
           action: #selector(dismissController)
       )
       // Do any additional setup after loading the view.
   }
   
   override func viewDidAppear(_ animated: Bool) {
//        if(isInitialized == false)
//        {
       let imagePickerController = UIImagePickerController()
       imagePickerController.delegate = self
       
       let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle:.actionSheet)
       
       actionSheet.addAction(UIAlertAction(title: "Camera", style:.default, handler:{(action: UIAlertAction) in
           
           if UIImagePickerController.isSourceTypeAvailable(.camera){
               imagePickerController.sourceType = .camera
               self.present(imagePickerController, animated: true, completion: nil)
           }else{
               print("Camera not available")
           }
       }))
       
       actionSheet.addAction(UIAlertAction(title: "Camera Roll",style: .default, handler: { (action:UIAlertAction) in
           imagePickerController.sourceType = .savedPhotosAlbum
           self.present(imagePickerController, animated: true, completion: nil)
       }))
       
       actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
       self.present(actionSheet, animated: true, completion: nil)
//        isInitialized = true
//        }
   }
   
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
       guard let selectedImage = info[.originalImage] as? UIImage else{
           fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
       }
       //imageView.image = selectedImage
       picker.dismiss(animated: true, completion: nil)
   }
   
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       picker.dismiss(animated: true, completion: nil)
   
   }
   
   @IBAction func chooseImage(_ sender: Any) {
       
       let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle:.actionSheet)
       actionSheet.addAction(UIAlertAction(title: "Camera", style:.default, handler:{(action: UIAlertAction) in }))
       actionSheet.addAction(UIAlertAction(title: "Photo Library",style: .default, handler: { (action:UIAlertAction) in}))
       actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       self.present(actionSheet, animated: true, completion: nil)
   }
   /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // Get the new view controller using segue.destination.
       // Pass the selected object to the new view controller.
   }
   */

   // MARK: - Actions for camera
   
   @objc private func dismissController() {
       dismiss(animated: true, completion: nil)
   }
}


-------------------
@objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else{
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        missingPersonImage.image = selectedImage
        picker.dismiss(animated: true, completion: nil)
    }
