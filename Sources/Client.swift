//
// Copyright 2016 iAchieved.it LLC
//
// MIT License (https://opensource.org/licenses/MIT)
//

import swiftlog
import Foundation
import MQTT

class Client:MQTT, MQTTDelegate {
  
  init(clientId:String) {
    super.init(clientId:clientId)
    super.delegate = self
  }
  
  func mqtt(mqtt: MQTT, didConnect host: String, port: Int) {
    SLogInfo("MQTT client \(mqtt.clientId) has connected to \(host):\(port)")
    NotificationCenter.defaultCenter().postNotification(ConnectedNotification)
  }
  
  func mqtt(mqtt: MQTT, didConnectAck ack: MQTTConnAck) {
    ENTRY_LOG()
  }
  
  func mqtt(mqtt: MQTT, didPublishMessage message: MQTTMessage, id: UInt16) {
    ENTRY_LOG()
  }
  
  func mqtt(mqtt: MQTT, didPublishAck id: UInt16) {
    ENTRY_LOG()
  }
  
  func mqtt(mqtt: MQTT, didReceiveMessage message: MQTTMessage, id: UInt16 ) {
    SLogInfo("didReceiveMessage")
    let userInfo:[String:Any] = ["message":message]
    NotificationCenter.defaultCenter().postNotificationName(MessageNotification.name,
                                                            object:nil,
                                                            userInfo:userInfo)
    
  }
  
  func mqtt(mqtt: MQTT, didSubscribeTopic topic: String) {
    SLogInfo("didSubscribeTopic \(topic)")
  }
  
  func mqtt(mqtt: MQTT, didUnsubscribeTopic topic: String) {
    ENTRY_LOG()
  }
  
  func mqttDidPing(mqtt: MQTT) {
    ENTRY_LOG()
  }
  
  func mqttDidReceivePong(mqtt: MQTT) {
    ENTRY_LOG()
  }
  
  func mqttDidDisconnect(mqtt: MQTT, withError err: NSError?) {
    ENTRY_LOG()
    SLogInfo("Disconnected from broker")
    NotificationCenter.defaultCenter().postNotification(DisconnectedNotification)
  }
}
