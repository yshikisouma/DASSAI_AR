import UIKit
import AVFoundation

class QRScannerController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!

    let captureSession = AVCaptureSession()
        var videoPreviewLayer:AVCaptureVideoPreviewLayer?
        var qrCodeFrameView:UIView!

    // 予約された会議室暗号
    var meetingRoomNo :String?
    //予約メンバー名
    var meetingMenber : String?
    //予約時間
    var meetingTime : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        //カメラが起動できない場合
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        //カメラ起動し、QRコードを読みとる
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            self.captureSession.startRunning()
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(topbar)
 
            qrCodeFrameView = UIView()
            // スキャンしたQRコードを緑の枠で囲む
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 5
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {
            print(error)
            return
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // データ読み取り確認
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        //ひとつ読み込んだら停止
        captureSession.stopRunning()
        //読み込んだデータを取得
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        //QRコード判定
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView.frame = barCodeObject!.bounds
            //QRコードからデータをよみとれた場合
            if metadataObj.stringValue != nil {
                //officeから予定表を取得。
                //予定表から会議室、時間、社員名を取得。

                messageLabel.text = metadataObj.stringValue
                meetingRoomNo = metadataObj.stringValue
            }
            FoundAlert(title: "こちらのQRコードでよろしいですか",message: "",segue:"MeetingRoomInfomartionController")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 戻るボタン押下時
    @IBAction func backScreen(_ sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    //次画面遷移処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //予約情報に会議室情報がある場合,会議室案内画面遷移。
        if meetingRoomNo != nil || meetingRoomNo !=  "" {
            let roomInformation: MeetingRoomInfomartionController = (segue.destination as? MeetingRoomInfomartionController)!
            //会議室名を取得し時画面に渡す
            roomInformation.meetingRoomName.text = meetingRoomNo
            FoundAlert(title: "会議室案内画面に遷移しますよ",message: "",segue: "MeetingRoomInfomartionController")
        //予約情報に会議室情報がない場合
        } else if meetingMenber != nil || meetingMenber != "" {
            //担当者呼び出し画面遷移準備
            let menberInformation :meetingMenberInformation  = (segue.destination as? meetingMenberInformation)!
            menberInformation.meetingMenber = meetingMenber
            FoundAlert(title: "担当者呼び出し画面面に遷移しますよ",message: "",segue: "meetingMenberInformation")
        } else {
            //取得できなかった場合、アラート表示
            notFoundAlert(title: "QRコードからご予約を見つけられません。再度ご確認の上QRコードをかざしてください",message: "")
        }
    }
    
    var alertController: UIAlertController!
    
    func notFoundAlert(title:String, message:String) {
        alertController = UIAlertController(title: title,message: message,preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",style: .default,handler: nil))
        present(alertController, animated: true)
        // iPad用の設定
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
           }
    }
    
    func FoundAlert(title:String, message:String, segue:String) {
        alertController = UIAlertController(title: title,message: message,preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK",style: UIAlertAction.Style.default,handler:{(action:UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: segue, sender: true)
        })
        let exitAction: UIAlertAction = UIAlertAction(title: "キャンセル",style: .default,handler : nil)
        alertController.addAction(okAction)
        alertController.addAction(exitAction)

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
           }
        present(alertController, animated: true, completion: nil)

        }
}
