//
//  GroupViewController.swift
//  BirdsVoice
//
//  Created by Zaini on 07/12/2020.
//

import UIKit
import CoreData

struct GroupData {
    var groupname = BData()
    var type = String()
}

class GroupViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    var birdArray = [BData]()
    var birds = [GroupData]()
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Groups"
        getData{
            for i in 0..<Birds.count{
                if let total = self.birdArray.firstIndex(where: {$0.Btype == Birds[i]}){
                    self.birds.append(GroupData(groupname: self.birdArray[total], type: Birds[i]))
                }
            }
            self.tableView.reloadData()
            print(self.birds)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as? groupViewCell else {return UITableViewCell()}
        cell.GroupName.text = birds[indexPath.row].type
        cell.GroupImg.image = UIImage.init(named: birds[indexPath.row].groupname.Btype)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "RecListController") as? RecListController{
            vc.isGroup = true
            let arr = birdArray.filter({$0.Btype == birds[indexPath.row].type})
            vc.birdArray = arr
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func getData(com:@escaping()->()) {
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
                com()
            }
        }catch{
            print("Data Fetching Error")
        }
    }

}

class groupViewCell:UITableViewCell{
    @IBOutlet weak var GroupName:UILabel!
    @IBOutlet weak var GroupImg:UIImageView!
    
    override func awakeFromNib() {
        GroupImg.roundView(with: GroupImg.frame.height/2)
    }
}
