import Glibc
import JSON

func randomAlphaNumericString(length: Int) -> String {

  srandom(UInt32(time(nil))) // Not foolproof but good enough for us

  let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  let charactersArray : [Character] = Array(charactersString.characters)
  
  var string = ""
  for _ in 0..<length {
    string.append(charactersArray[Int(random()) % (charactersArray.count)])
  }
               
  return string
}

func chatMessageFor(clientId:String, andMessage message:String) -> String {
  let json:JSON = [
    "client":.infer(clientId),
    "message":.infer(message)
  ]
  return JSONSerializer().serializeToString(json: json)
}
