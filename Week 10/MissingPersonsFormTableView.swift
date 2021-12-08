//
//  MissingPersonTableViewController.swift
//  BeachGuardian
//

import UIKit
import AWSS3

class MissingPersonTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
    let transferManager = AWSS3TransferManager.default()
    var contentURL: URL!
    var s3Url: URL!
    var bucketName = "lifehaloios-deployments-mobilehub-641691893"
    var s3Error = false
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var hairColorField: UITextField!
    @IBOutlet weak var clothingField: UITextField!
    @IBOutlet weak var contactFirst: UITextField!
    @IBOutlet weak var contactLast: UITextField!
    @IBOutlet weak var contactPhone: UITextField!
    @IBOutlet weak var contactPhone2: UITextField!
    
    @IBOutlet var mainTable: UITableView!
    
    
    // picker-array contents
    let locations = ["Water","Shore","Tower","Back"]
    let times = ["5 Minutes Ago", "10 Minutes Ago", "30 Minutes Ago", "1 Hour Ago", "Over 1 Hour Ago"]
    let ethnicity = ["American Indian/Alaskan", "Asian", "African American", "White", "Hispanic/Latino", "Hawaiian or Pacific Islander", "Other"]
    let direction = ["North", "North East", "East", "South East", "South", "South West", "West", "North West"]
    
    // these will hold variables for text fields
    var name = ""
    var age = ""
    var hairColor = ""
    var clothing = ""
    var contactFirstName = ""
    var contactLastName = ""
    var contactPhoneNum = ""
    var contactPhoneNum2 = ""
    
    // these will hold selected picker values
    var selectedLocation = ""
    var selectedTime = ""
    var selectedEthnicity = ""
    var selectedDirection = ""
    
    // these will hold checkbox values
    var male = false
    var female = false
    
    var holderImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        missingPersonImage.image = holderImage

        locationPicker.delegate = self
        locationPicker.dataSource = self
        locationPicker.tag = 1
        locationPicker.accessibilityIdentifier = "picker-location"
        
        lastSeenPicker.delegate = self
        lastSeenPicker.dataSource = self
        lastSeenPicker.tag = 2
        lastSeenPicker.accessibilityIdentifier = "picker-lastSeen"
        
        ethnicityPicker.delegate = self
        ethnicityPicker.dataSource = self
        ethnicityPicker.tag = 3
        ethnicityPicker.accessibilityIdentifier = "picker-ethnicity"
        
        directionPicker.delegate = self
        directionPicker.dataSource = self
        directionPicker.tag = 4
        directionPicker.accessibilityIdentifier = "picker-direction"
        
        // these hold values of the picker selection
        selectedLocation = locations[0]
        selectedTime = times[0]
        selectedEthnicity = ethnicity[0]
        selectedDirection = direction[0]
        
        nameField.delegate = self
        nameField.tag = 10
        nameField.accessibilityIdentifier = "textField-name"
        
        ageField.delegate = self
        ageField.tag = 11
        ageField.accessibilityIdentifier = "textField-age"
        
        hairColorField.delegate = self
        hairColorField.tag = 12
        hairColorField.accessibilityIdentifier = "textField-hairColor"
        
        clothingField.delegate = self
        clothingField.tag = 13
        clothingField.accessibilityIdentifier = "textField-clothing"
        
        contactFirst.delegate = self
        contactFirst.tag = 14
        contactFirst.accessibilityIdentifier = "textField-contactFirst"
        
        contactLast.delegate = self
        contactLast.tag = 15
        contactLast.accessibilityIdentifier = "textField-contactLast"
        
        contactPhone.delegate = self
        contactPhone.tag = 16
        contactPhone.accessibilityIdentifier = "textField-contactPhone"
        
        contactPhone2.delegate = self
        contactPhone2.tag = 17
        contactPhone2.accessibilityIdentifier = "textField-contactPhone2"
        
    }
    
    // called when user stops editing corresponding text field so we can save that selection to a variable
    func textFieldDidEndEditing(_ textField: UITextField) {
        return textFieldValue(textField.tag)
    }
    func textFieldValue(_ tag: Int){
        if(tag == 10){
            name = nameField.text ?? ""
            print(name)
        }
        else if(tag == 11){
            age = ageField.text ?? ""
        }
        else if(tag == 12){
            hairColor = hairColorField.text ?? ""
        }
        else if(tag == 13){
            clothing = clothingField.text ?? ""
        }
        else if(tag == 14){
            contactFirstName = contactFirst.text ?? ""
        }
        else if(tag == 15){
            contactLastName = contactLast.text ?? ""
        }
        else if(tag == 16){
            contactPhoneNum = contactPhone.text ?? ""
        }
        else{
            contactPhoneNum2 = contactPhone.text ?? ""
        }
    }
    
    
    @IBOutlet weak var locationPicker: UIPickerView!
    
    @IBOutlet weak var lastSeenPicker: UIPickerView!
    
    @IBOutlet weak var ethnicityPicker: UIPickerView!
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    @IBOutlet weak var directionPicker: UIPickerView!
    
    @IBOutlet weak var towerSlider: UISlider!
    
    @IBOutlet weak var towerLabel: UILabel!
    
    var sliderValue = 5 // store slider's value
    @IBAction func sliderValueChanged(_ sender: Any) {
        towerLabel.text = "\(Int(towerSlider.value))"
        sliderValue = Int(towerSlider.value)
    }
    
    @IBOutlet weak var missingPersonImage: UIImageView!
    
    @IBAction func takePhoto(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }else{
            print("Camera not available")
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    

    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else{
                return
        }
        missingPersonImage.image = selectedImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitReport(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        submitReportUsingPhoto(missingPersonImage: missingPersonImage)
    }
    
    func submitReportUsingPhoto(missingPersonImage : UIImageView? ){
        s3Url = AWSS3.default().configuration.endpoint.url
        guard let image = missingPersonImage?.image else {
            displayNoPictureMessage()
            return
        }
        
        if missingPersonImage == UIImage(named: "camera") {
        }
        else{ }
        //convert image to png
        let pngImage = image.pngData()
        let fileName = "missing.png"
        //URL function generates url that we will be uploading to
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let key = ProcessInfo.processInfo.globallyUniqueString + ".png"
        
        do{
            try pngImage?.write(to: fileURL)
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = fileURL
            uploadRequest?.key = key
            uploadRequest?.bucket = bucketName
            uploadRequest?.contentType = "image/png"
            uploadRequest?.acl = .publicReadWrite
            
            //processRequest(transferManager: transferManager, uploadRequest: uploadRequest!, key: key, fileURL: fileURL, on: DispatchQueue(label: ""))
            processRequest(transferManager: transferManager, uploadRequest: uploadRequest!, key: key, fileURL: fileURL){ success in print("success")}
            
        }
        catch{
            print("File not saved")
        }
    }
    
    func processRequest(transferManager : AWSS3TransferManager, uploadRequest: AWSS3TransferManagerUploadRequest, key: String, fileURL: URL, completion: @escaping(Bool) ->()){
        transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread()) {(task) -> Any? in
        
    if let error = task.error{
        print("Upload failed with error: (\(error.localizedDescription))")
        self.s3Error = true
        completion(true)
        return nil
    }
    if task.result != nil {
    self.dismissAlert()
    let contentURL = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
    self.contentURL = contentURL
    print("Uploaded \(fileURL) successfully to S3. The url is:\(contentURL)")
    }
    self.displaySubmittedMessage()
    completion(true)
            self.s3Error = false
    return nil
    }
}
    
internal func dismissAlert() { if let vc = self.presentedViewController, vc is UIAlertController { dismiss(animated: false, completion: nil) } }

func displaySubmittedMessage()
{
    let alertController = UIAlertController(title: "Report Submitted", message: "Your report has been submitted", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) {(action: UIAlertAction!) in }
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
}

func displayNoPictureMessage()
{
    let alertController = UIAlertController(title: "No picture chosen", message: "You have not uploaded a picture to be submitted", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) {(action: UIAlertAction!) in }
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
}

override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 12
}

func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
}

// if the user selects a row, store the input
func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    return pickerViewSelect(pickerView.tag, row)
}
func pickerViewSelect(_ tag: Int, _ row: Int){
    if(tag == 1){
        selectedLocation = locations[row]
        print(selectedLocation)
    }
    else if(tag == 2){
        selectedTime = times[row]
    }
    else if(tag == 3){
        selectedEthnicity = ethnicity[row]
    }
    else{
        selectedDirection = direction[row]
    }
}

func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerViewCount(pickerView.tag)
}

func pickerViewCount(_ tag: Int) -> Int {
    if(tag == 1){
        return locations.count
    }
    else if(tag == 2){
        return times.count
    }
    else if(tag == 3){
        return ethnicity.count
    }
    return direction.count
}

// displays what's in the arrays in corresponding picker
func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerViewContent(pickerView.tag, row)
}

func pickerViewContent(_ tag: Int, _ row: Int) -> String?{
    if(tag == 1){
        return locations[row]
    }
    else if(tag == 2){
        return times[row]
    }
    else if(tag == 3){
        return ethnicity[row]
    }
    
    return direction[row]
}

// update corresponding checkbox and boolean values
@IBAction func maleButtonClicked(_ sender: UIButton) {
    // update values
    male = true
    female = false
    
    sender.isSelected = !sender.isSelected
    if femaleButton.isSelected{
        femaleButton.isSelected = !femaleButton.isSelected
    }
}

// update corresponding checkbox and boolean values
@IBAction func femaleButtonClicked(_ sender: UIButton) {
    // update values
    male = false
    female = true
    
    sender.isSelected = !sender.isSelected
    if maleButton.isSelected{
        maleButton.isSelected = !maleButton.isSelected
    }
}
}
