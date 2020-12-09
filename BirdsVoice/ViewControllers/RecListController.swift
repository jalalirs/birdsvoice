//
//  RecListController.swift
//  BirdsVoice
//
//  Created by Zaini on 05/12/2020.
//

import UIKit
import CoreData
import AVFoundation
import Alamofire
import AFNetworking
import SwiftyJSON

struct BData {
    var Btype = String()
    var Name = String()
    var Pics = UIImage()
}
class RecListController: UIViewController,AVAudioPlayerDelegate {

    var birdArray = [BData]()
    var audioPlayer : AVAudioPlayer?
    var numofRecords = 0
    var isClassify = false
    var isGroup = false
    var index = 0
    @IBOutlet weak var tableView:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recordings"
        audioPlayer?.volume = 1.0
        numofRecords = UserDefaults.standard.integer(forKey: "total")
        if !isGroup{
            getData()
        }
        tableView.reloadData()
    }
    
    func getData() {
        self.birdArray.removeAll()
        let managedObjectContex =  (UIApplication.shared.delegate as! AppDelegate).persistant.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Info")
        request.returnsObjectsAsFaults = false
        do{
            let results = try managedObjectContex.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        if let type = result.value(forKey: "type") as? String {
                              if let image = UIImage(named: type){
                                   birdArray.append(BData(Btype: type, Name: name, Pics: image))
                            }
                        }
                    }
                }
            }
        }catch{
            print("Data Fetching Error")
        }
    }
    
}
extension RecListController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "birdCell", for: indexPath) as? RecordingListCell else {return UITableViewCell()}
        cell.nameLbl.text = birdArray[indexPath.row].Name
        cell.typeLbl.text = birdArray[indexPath.row].Btype
        cell.birdImg.image = birdArray[indexPath.row].Pics
        if isClassify{
            cell.classify.isHidden = false
        }
        cell.playbtn.addTarget(self, action: #selector(playBtn(sender:)), for: .touchDown)
      //  cell.nameLbl.text = "Bird Recording \(indexPath.row + 1)"
        cell.classify.addTarget(self, action: #selector(classifyBtn), for: .touchDown)
        cell.playbtn.tag = indexPath.row
        cell.classify.tag = indexPath.row
        return cell
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func postToServer(tag: Int){
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        let host = "http://192.168.100.15:8080/prediction"
        let filename = "\(tag+1).m4a"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            let audio = try Data(contentsOf: fileURL)
            manager.post(host, parameters: nil,
                         constructingBodyWith: { (data: AFMultipartFormData!) in
                            data.appendPart(withFileData: audio, name: "file",fileName: filename, mimeType: "audio/m4a")
                        },
                        success: { task, responseObject in
                            let json = JSON(responseObject)
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ClassificationController") as? ClassificationController{
                                vc.json = json.rawString()!
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        },
                        failure: {
                                (operation: AFHTTPRequestOperation!,error: Error!) in
                                print(error)
                        })
        } catch  {
            
        }
        
        
        
       
    }

    @objc func classifyBtn(sender:UIButton){
       
            postToServer(tag: sender.tag)
           
    }
    
    
    
    @objc func playBtn(sender:UIButton){
        if sender.imageView?.image?.pngData() == #imageLiteral(resourceName: "play-button").pngData(){
            var error : NSError?
            do {
                
              //  let url = URL(string: )!
                index = sender.tag
                
                let player = try AVAudioPlayer(contentsOf: getDocumentsDirectory().appendingPathComponent("\(sender.tag + 1).m4a"))
                 audioPlayer = player
                player.delegate = self
             } catch {
                 print(error)
             }
            audioPlayer?.delegate = self
            if let err = error{
                print("audioPlayer error: \(err.localizedDescription)")
             }else{
                audioPlayer?.play()
             }
            sender.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }else{
            sender.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
            audioPlayer?.pause()
        }
    }
    
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
               // textField.text = self.list[indexPath.row]
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
             //   self.list[indexPath.row] = alert.textFields!.first!.text!
             //   self.tableView.reloadRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })

        return [editAction]
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finshed")
        let ind = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: ind) as? RecordingListCell{
            cell.playbtn.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
        }
    }
}

class RecordingListCell: UITableViewCell {
    
    @IBOutlet weak var birdImg:UIImageView!
    @IBOutlet weak var nameLbl:UILabel!
    @IBOutlet weak var typeLbl:UILabel!
    @IBOutlet weak var playbtn:UIButton!
    @IBOutlet weak var classify:UIButton!
    
    override func awakeFromNib() {
        birdImg.roundView(with: birdImg.frame.height/2)
    }
}
