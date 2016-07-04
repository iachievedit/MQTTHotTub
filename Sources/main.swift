//
// Copyright 2016 iAchieved.it LLC
//
// MIT License (https://opensource.org/licenses/MIT)
//

import swiftlog
import Glibc
import Foundation
import MQTT
import JSON

slogLevel = .Info // Change to .Verbose to get real chatty

srandom(UInt32(time(nil)))

let clientId = randomAlphaString(length:8)
let client = Client(clientId:clientId)
client.host = "broker.hivemq.com"
client.keepAlive = 60

let nc = NotificationCenter.defaultCenter()

var saySomething:Timer?

_ = nc.addObserverForName(DisconnectedNotification.name, object:nil, queue:nil){_ in
  SLogInfo("Connecting to broker")

  saySomething?.invalidate()
  if !client.connect() {
    SLogError("Unable to connect to broker.hivemq.com, retrying in 30 seconds")
    let retryInterval     = 30
    let retryTimer        = Timer.scheduledTimer(withTimeInterval:TimeInterval(retryInterval),
                                                   repeats:false){ _ in
      nc.postNotification(DisconnectedNotification)
    }
    RunLoop.current().add(retryTimer, forMode:RunLoopMode.defaultRunLoopMode)
  }
}

_ = nc.addObserverForName(ConnectedNotification.name, object:nil, queue:nil) {_ in

  let reportInterval    = 10
  saySomething = Timer.scheduledTimer(withTimeInterval:TimeInterval(reportInterval),
                                        repeats:true){_ in
    if client.connState == .CONNECTED {
      let message = chatMessageFor(clientId:clientId,
                                   andMessage:randomSentence())
      _ = client.publish(topic:"/chat/hottub", withString:message)
      SLogInfo("Published \(message) to /chat/hottub")
    } else {
      SLogError("MQTT client is not connected")
    }
  }

  _ = client.subscribe(topic:"/chat/hottub")
  _ = client.subscribe(topic:"/chat/SYSTEM")

  RunLoop.current().add(saySomething!, forMode:RunLoopMode.defaultRunLoopMode)

}

_ = nc.addObserverForName(MessageNotification.name, object:nil, queue:nil){ notification in
  if let userInfo = notification.userInfo,
     let message  = userInfo["message"] as? MQTTMessage {
    do {
      let bytes = Data(bytes:message.payload)//, length:message.payload.count)
      if let json = try JSONSerialization.jsonObject(with:bytes, options:[]) as? [String:Any] {
        let cid = json["client"] as! String
        let msg = json["message"] as! String
        if cid != clientId {
          SLogInfo("Received \"\(msg)\" from \(cid)")
        }
      }
    } catch {
      SLogError("Malformed message payload")
    }
  } else {
    SLogError("Unable to obtain MQTT message")
  }
}

nc.postNotification(DisconnectedNotification) // Kick the connection

let heartbeat = Timer.scheduledTimer(withTimeInterval:TimeInterval(30), repeats:true){_ in return}
RunLoop.current().add(heartbeat, forMode:RunLoopMode.defaultRunLoopMode)
RunLoop.current().run()

