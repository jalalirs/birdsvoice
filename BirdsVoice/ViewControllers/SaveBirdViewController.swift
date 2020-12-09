//
//  SaveBirdViewController.swift
//  BirdsVoice
//
//  Created by Zaini on 06/12/2020.
//

import UIKit
import AVFoundation
import CoreData
var Birds = ["Myna", "Hoopoe", "Dove","Bulbul","Sparrow","Unknown"]
class SaveBirdViewController: UIViewController,ImagePickerDelegate, AVAudioRecorderDelegate,AVAudioPlayerDelegate {
  

    @IBOutlet weak var micImg:UIImageView!
    @IBOutlet weak var micLbl:UILabel!
    @IBOutlet weak var stopbtn:UIButton!
    @IBOutlet weak var PicImg:UIImageView!
    @IBOutlet weak var picUpload:UIButton!
    @IBOutlet weak var dropbtn:UIButton!
    @IBOutlet weak var savebtn:UIButton!
    @IBOutlet weak var cancelbtn:UIButton!
    @IBOutlet weak var BirdName:UITextField!
    var dropDown = DropDown()
    var imagePicker : ImagePicker!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer?
    var numofRecords = 0
    var count = 10
    var timer : Timer!
    var audioUrl = String()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bird Info"
        numofRecords = UserDefaults.standard.integer(forKey: "total")
        micImg.loadGif(asset: "mic")
        PicImg.roundView(with: PicImg.frame.height/2)
        BirdName.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        micLbl.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        micImg.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        stopbtn.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        savebtn.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        cancelbtn.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        picUpload.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        dropbtn.roundView(with: 10, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), 1, false)
        dropDown.anchorView = dropbtn
        dropDown.dataSource = Birds
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            PicImg.image = UIImage.init(named: item)
            dropbtn.setTitle(item, for: .normal)
        }
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        setupAudio()
    }
    
    private func setupAudio(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            
            try recordingSession.setCategory(.playAndRecord, mode: .spokenAudio,options: [.defaultToSpeaker])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        startRecording()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    var imgUrl = String()
    func didSelect(image: URL?) {
        if let chatImage = image{
            imgUrl = chatImage.absoluteString
             let imageData = try! Data(contentsOf: chatImage)
             let img = UIImage(data: imageData)
             PicImg.image = img
        }
    }
    
    
    @IBAction func stopRecord(sender:UIButton){
        if sender.titleLabel?.text == "Play Recording"{
            var error : NSError?
            do {
                let url = URL(string: audioUrl)!
                let player = try AVAudioPlayer(contentsOf: url)
                 audioPlayer = player
             } catch {
                 print(error)
             }
            audioPlayer?.delegate = self
            if let err = error{
                print("audioPlayer error: \(err.localizedDescription)")
             }else{
                audioPlayer?.play()
             }
        }else{
            finishRecording(success: true)
        }
       
    }
    
    @objc func update() {
        if(count > 0) {
            count -= 1
            micLbl.text = "\(count) Seconds"
        }else{
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        numofRecords += 1
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(numofRecords).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        timer.invalidate()
        timer = nil
        if success {
            audioUrl = audioRecorder.url.absoluteString
            stopbtn.setTitle("Play Recording", for: .normal)
        }
        audioRecorder = nil
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func dropBtn(sender:UIButton){
        dropDown.show()
    }
    
    
    func SaveVideo(){
        let managedObjectContex =  delegate.persistant.viewContext
        managedObjectContex.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
        let objectInfo = NSEntityDescription.insertNewObject(forEntityName: "Info",into: managedObjectContex)
        UserDefaults.standard.set(numofRecords, forKey: "total")
        objectInfo.setValue(BirdName.text ?? "", forKey: "name")
        objectInfo.setValue(dropbtn.titleLabel?.text ?? "Myna", forKey: "type")
        do{
            try managedObjectContex.save()
            print("dataSaved")
            let alert = UIAlertController(title: "Success", message: "Information has been saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }catch{
            print("error")
        }
    }
    
    @IBAction func saveBtn(sender:UIButton){
        if !(BirdName.text?.trimmingCharacters(in: .whitespaces).isEmpty)! && !(dropbtn.titleLabel!.text!.trimmingCharacters(in: .whitespaces).isEmpty) && audioUrl != ""{
            SaveVideo()
        }else{
            let alert = UIAlertController(title: "Warning", message: "Please fill all information", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it.", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func uploadImage(){
        imagePicker.present(from: self.view)
    }
    
    
    @IBAction func cancelBtn(){
        navigationController?.popViewController(animated: true)
    }

}
