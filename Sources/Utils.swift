import Glibc
import JSON

func randomAlphaNumericString(length: Int) -> String {
  let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  let charactersArray : [Character] = Array(charactersString.characters)
  
  var string = ""
  for _ in 0..<length {
    string.append(charactersArray[Int(random()) % (charactersArray.count)])
  }
               
  return string
}

func chatMessageFor(clientId:String, andMessage message:String) -> String {
    /*
  let json:JSON = [
    "client":clientId,
    "message":message
  ]
  do {
    let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
    // here "jsonData" is the dictionary encoded in JSON data

    let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
    // here "decoded" is an `AnyObject` decoded from JSON data

    // you can now cast it with the right type        
    if let dictFromJSON = decoded as? [String:String] {
        // use dictFromJSON
    }
} catch let error as NSError {
    print(error)
  }
*/
  let json:JSON = [
    "client":.infer(clientId),
    "message":.infer(message)
  ]
  return JSONSerializer().serializeToString(json: json)
}
