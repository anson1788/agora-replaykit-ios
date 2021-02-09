//
//  LiveRoomViewController.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit
import AgoraRtcKit
import ReplayKit


class LiveRoomViewController: UIViewController {
    
    @IBOutlet weak var broadcastersView: AGEVideoContainer!
    @IBOutlet weak var placeholderView: UIImageView!
    
    @IBOutlet weak var videoMuteButton: UIButton!
    @IBOutlet weak var audioMuteButton: UIButton!
    @IBOutlet weak var beautyEffectButton: UIButton!
    
    @IBOutlet var sessionButtons: [UIButton]!
    

    
    var kit:AgoraRtcEngineKit?
    private var agoraKit: AgoraRtcEngineKit {
        if kit==nil{
            kit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)
        }
        return self.kit!
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAgoraKit()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - ui action
    @IBAction func doSwitchCameraPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func doBeautyPressed(_ sender: UIButton) {
       
    }
    
    @IBAction func doMuteVideoPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func doMuteAudioPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func doLeavePressed(_ sender: UIButton) {

    }
}



//MARK: - Agora Media SDK
private extension LiveRoomViewController {
    
    private static let videoDimension : CGSize = {
        let screenSize = UIScreen.main.currentMode!.size
        var boundingSize = CGSize(width: 720, height: 1280)
        let mW = boundingSize.width / screenSize.width
        let mH = boundingSize.height / screenSize.height
        if( mH < mW ) {
            boundingSize.width = boundingSize.height / screenSize.height * screenSize.width
        }
        else if( mW < mH ) {
            boundingSize.height = boundingSize.width / screenSize.width * screenSize.height
        }
        return boundingSize
    }()
    func loadAgoraKit() {
        let channelId = "iosTestClient"
      
     
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.broadcaster)
     
        agoraKit.enableVideo()
        agoraKit.setExternalVideoSource(true, useTexture: true, pushMode: true)
        let videoConfig = AgoraVideoEncoderConfiguration(size: LiveRoomViewController.videoDimension,
                                                         frameRate: .fps24,
                                                         bitrate: AgoraVideoBitrateStandard,
                                                         orientationMode: .adaptative)
        
        agoraKit.setVideoEncoderConfiguration(videoConfig)
        agoraKit.setAudioProfile(.musicStandardStereo, scenario: .default)
        
        agoraKit.muteAllRemoteVideoStreams(true)
        agoraKit.muteAllRemoteAudioStreams(true)
        
        // Step 5, join channel and start group chat
        // If join  channel success, agoraKit triggers it's delegate function
        // 'rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int)'
        agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channelId, info: nil, uid: 0, joinSuccess: nil)
        

            RPScreenRecorder.shared().startCapture( handler: { (sample, bufferType, error) in
              //  self.recordingErrorHandler(error)
                if (bufferType == .video) {
                    //self.capturer?.didCapture(sample)
                    self.sendVideoBuffer(sample)
                }
                
            }, completionHandler: { error in
                if error == nil {
                  //  self.status = "Broadcast started in room with id: \(self.lastRoomID ?? "")"
                }
                //self.recordingErrorHandler(error)
            })
       
    }
    func sendVideoBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer)
             else {
            return
        }
        print("data here")
        var rotation : Int32 = 0
        if let orientationAttachment = CMGetAttachment(sampleBuffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil) as? NSNumber {
            if let orientation = CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value) {
                switch orientation {
                case .up,    .upMirrored:    rotation = 0
                case .down,  .downMirrored:  rotation = 180
                case .left,  .leftMirrored:  rotation = 90
                case .right, .rightMirrored: rotation = 270
                default:   break
                }
            }
        }
        
        //let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let time = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 1000)
        
        let frame = AgoraVideoFrame()
        frame.format = 12
        frame.time = time
        frame.textureBuf = videoFrame
        frame.rotation = rotation
        agoraKit.pushExternalVideoFrame(frame)
        print("data here  11 \(frame)")
    }
 

}
