//
//  ClassificationController.swift
//  BirdsVoice
//
//  Created by Zaini on 06/12/2020.
//

import UIKit
import Foundation
struct Classification: Codable {
    let name: String
    let probability: Float
}
extension String {

    func parse<D>(to type: D.Type) -> D? where D: Decodable {

        let data: Data = self.data(using: .utf8)!

        let decoder = JSONDecoder()

        do {
            let _object = try decoder.decode(type, from: data)
            return _object

        } catch {
            return nil
        }
    }
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
   
}
class ClassificationController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    //var Bird = BirdClassify()
    var json = String()
    var parsedData = [Classification]()
    @IBOutlet weak var birdImg:UIImageView!
    var spinner = UIActivityIndicatorView(style: .large)
    var myView = UIView()
   @IBOutlet weak var tableview : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parsedData = json.parse(to: [Classification].self)!
        let bestClass = self.parsedData[0].name.capitalizingFirstLetter()
        birdImg.image =  UIImage.init(named: bestClass)
        //title = json["Name"]
        //Indicator()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
//            birdImg.image =  UIImage.init(named: json["Type"]!)
//            birdImg.setViewCard()
//
//            Bird = BirdClassify(Mynah: ["Noisy Miner        71.5%", "Mynah          98.2%","Launday Pole            64.2%"], Hoopoe: ["Upopa            63.4%", "Beak           71.0%","Hoopoe          94.9%", "Naml           85.3%"], Dove: ["Ice Pigeon         59.2%","Rock Pigeon         76.9%","White Tipped Dove           61.8%","Dove            96.2%"], Bulbul: ["Black-crested            78.3%","Red Vented          69.2%", "Sooty-headed           98.7%", "Brown-brested          91.0%" ], Sparrow: ["American Tree Sparrow           83.2%", "Chipping Sparrow          79.1%", "Carolina Wren          32.6%","House Sparrow            98.7%", "White-throated Sparrow         62.0%"],TrueIndex: [1,2,3,2,3])
//
//
//            let mirror = Mirror(reflecting: self.Bird)
//            if let index = mirror.children.firstIndex(where: { $0.label == self.json["Type"]! as String}){
//                self.selectedArr = (mirror.children[index].value) as! [String]
//                self.selectiIndex = (mirror.children.enumerated().map({$0.element}).firstIndex(where: {$0.label == self.json["Type"]! as String})!)
//            }
//            spinner.stopAnimating()
//            myView.removeFromSuperview()
//            self.tableview.reloadData()
//        }
    }
    
    
    func Indicator(){
        myView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        myView.center = view.center
        myView.roundView(with: 10)
        myView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let strLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        strLabel.text = "Waiting"
        strLabel.center.y = spinner.center.y + 65
        strLabel.center.x = spinner.center.x + 45
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        spinner.startAnimating()
        myView.addSubview(spinner)
        myView.addSubview(strLabel)
        view.addSubview(myView)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parsedData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0{
            cell.backgroundColor = UIColor.green
        }
        let sprob = NSString(format: "%.2f", self.parsedData[indexPath.row].probability)  as String
        cell.textLabel?.text =  self.parsedData[indexPath.row].name.padding(toLength: 20, withPad: " ", startingAt: 0) + sprob+"%"
       return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
