//
//  MeetingInformationController.swift
//  DASSAI_AR
//
//  Created by 相馬祥希 on 2020/11/02.
//

import Foundation
import UIKit

class MeetingRoomInfomartionController: UIViewController {

    // 会議室の地図
    @IBOutlet weak var officeMap: UIImageView!
    //会議室番号
    var meetingRoomNo : String?
    //会議室名
    @IBOutlet weak var meetingRoomName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //会議室番号に紐づく会議室地図を取得し表示
        
    }
    
    @IBAction func backScreen(_ sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}
