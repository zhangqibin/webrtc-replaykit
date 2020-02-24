//
// Copyright © 2019 Robert Bosch GmbH. All rights reserved. 
    

import Foundation
import WebRTC
import WebRTCDemoSignalling
import ReplayKit
import os.log

class WebRTCBroadcastModelView: NSObject, ObservableObject {
    let client: ARDAppClient = ARDAppClient()
    let logging = RTCCallbackLogger()
    var capturer: ARDExternalSampleCapturer?
    @Published var broadcastRoomID: String = ""
    @Published var status: String = ""
    var lastRoomID: String?

    override init() {
        super.init()

        self.client.delegate = self
        self.logging.start { (logMessage: String, _) in
            OSLog.info(logMessage: logMessage, log: OSLog.webRTC)
        }
    }

    private var broadcastRandomRoomID: String {
        "broadcast_\(Int.random(in: 1 ... 1000))"
    }

    public func startBroadcast(to roomID: String?) {
        let settings = ARDSettingsModel()
        client.isBroadcast = true
        let roomID = roomID ?? self.broadcastRandomRoomID
        self.lastRoomID = roomID
        client.connectToRoom(withId: roomID, settings: settings, isLoopback: false)

        let logMessage = "Try to connect to room \(roomID)"
        self.status = logMessage
        OSLog.info(logMessage: logMessage, log: OSLog.app)
    }

    private func startScreenCapturing() {
        RPScreenRecorder.shared().startCapture(handler: { (sample, bufferType, error) in
            self.recordingErrorHandler(error)
            if (bufferType == .video) {
                self.capturer?.didCapture(sample)
            }
            
        }, completionHandler: { error in
            if error == nil {
                self.status = "Broadcast started in room with id: \(self.lastRoomID ?? "")"
            }
            self.recordingErrorHandler(error)
        })
    }

    private func recordingErrorHandler(_ error: Error?) {
        guard let error = error else {
            return
        }
        self.status = error.localizedDescription
        OSLog.info(logMessage: error.localizedDescription, log: OSLog.app)
    }
}

extension WebRTCBroadcastModelView: ARDAppClientDelegate {
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
    }

    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
    }

    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
    }

    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
    }

    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
    }

    func appClient(_ client: ARDAppClient!, didCreateLocalExternalSampleCapturer externalSampleCapturer: ARDExternalSampleCapturer!) {
        self.capturer = externalSampleCapturer
        self.startScreenCapturing()
    }

    func appClient(_ client: ARDAppClient!, didError error: Error!) {
    }

    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
    }

}
