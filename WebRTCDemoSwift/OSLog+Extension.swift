//
// Copyright © 2019 Robert Bosch GmbH. All rights reserved. 
    

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    private static let kLogSybsystem = "com.google.WebRTCDemoSwift"
    private static let kWebRTCLogCategory = "RTCLog"
    private static let kAppLogCategory = "App"

    /// Logs the view cycles like viewDidLoad.
    static let webRTC = OSLog(subsystem: OSLog.kLogSybsystem, category: OSLog.kWebRTCLogCategory)
    static let app = OSLog(subsystem: OSLog.kLogSybsystem, category: OSLog.kAppLogCategory)

    static func info(logMessage: String, log: OSLog) {
        os_log("%{public}@", log: OSLog.webRTC, type: .info, logMessage)
    }
}
