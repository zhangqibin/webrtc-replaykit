//
// Copyright © 2019 Robert Bosch GmbH. All rights reserved. 
    

import SwiftUI

struct ContentView: View {

    @ObservedObject var modelView = WebRTCBroadcastModelView()

    var body: some View {
        VStack {
            Spacer()
            TextField("Broadcast Room ID:", text: self.$modelView.broadcastRoomID)
            Spacer()
            Button(action: {
                self.modelView.startBroadcast(to: self.modelView.broadcastRoomID)
            }) {
                Text("Start broadcasting")
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
