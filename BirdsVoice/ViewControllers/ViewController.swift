//
//  ViewController.swift
//  BirdsVoice
//
//  Created by Zaini on 02/12/2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func optionBtn(sender:UIButton){
        switch sender.tag {
        case 0:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "SaveBirdViewController") as? SaveBirdViewController{
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "RecListController") as? RecListController{
                navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "GroupViewController") as? GroupViewController{
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "RecListController") as? RecListController{
                vc.isClassify = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
