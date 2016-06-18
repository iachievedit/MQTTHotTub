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

let clientId = randomAlphaNumericString(length:8)
let client = Client(clientId:clientId)
client.host = "broker.hivemq.com"
client.keepAlive = 60

let nc = NSNotificationCenter.defaultCenter()

var saySomething:NSTimer?

_ = nc.addObserverForName("DisconnectedNotification", object:nil, queue:nil){_ in
  SLogInfo("Connecting to broker")

  saySomething?.invalidate()
  if !client.connect() {
    SLogError("Unable to connect to broker.hivemq.com, retrying in 30 seconds")
    let retryInterval     = 30
    let retryTimer        = NSTimer.scheduledTimer(NSTimeInterval(retryInterval),
                                                   repeats:false){ _ in
      nc.postNotificationName("DisconnectedNotification", object:nil)
    }
    NSRunLoop.currentRunLoop().addTimer(retryTimer, forMode:NSDefaultRunLoopMode)
  }
}

_ = nc.addObserverForName("ConnectedNotification", object:nil, queue:nil) {_ in

  let reportInterval    = 10
  saySomething = NSTimer.scheduledTimer(NSTimeInterval(reportInterval),
                                        repeats:true){_ in
    if client.connState == .CONNECTED {
      let message = chatMessageFor(clientId:clientId,
                                   andMessage:randomAlphaNumericString(length:16))
      _ = client.publish(topic:"/chat/hottub", withString:message)
      SLogInfo("Published \(message) to /chat/hottub")
    } else {
      SLogError("MQTT client is not connected")
    }
  }

  _ = client.subscribe(topic:"/chat/hottub")

  NSRunLoop.currentRunLoop().addTimer(saySomething!, forMode:NSDefaultRunLoopMode)

}

_ = nc.addObserverForName("MessageNotification", object:nil, queue:nil){ notification in
  if let userInfo = notification.userInfo,
     let message  = userInfo["message" as NSString] as? MQTTMessage {
    do {
      let bytes = NSData(bytes:message.payload, length:message.payload.count)
      if let json = try NSJSONSerialization.jsonObject(with:bytes, options:[]) as? [String:Any] {
        let cid = json["client"] as! String
        let msg = json["message"] as! String
        if cid != clientId {
          SLogInfo("Received \(msg) from \(cid)")
        }
      }
    } catch {
      SLogError("Malformed message payload")
    }
  } else {
    SLogError("Unable to obtain MQTT message")
  }
}

nc.postNotificationName("DisconnectedNotification", object:nil) // Kick the connection

let heartbeat = NSTimer.scheduledTimer(NSTimeInterval(30), repeats:true){_ in return}
NSRunLoop.currentRunLoop().addTimer(heartbeat, forMode:NSDefaultRunLoopMode)
NSRunLoop.currentRunLoop().run()

