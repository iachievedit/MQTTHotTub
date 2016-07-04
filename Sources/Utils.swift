import Glibc
import JSON
import Foundation

func randomSentence() -> String {
  srandom(UInt32(time(nil)))
  let wordCount = Int(random() % 10) + 1
  var sentence:String = ""
  for w in 1...wordCount {
    let wordLength = Int(random() % 8) + 1
    let word       = randomAlphaString(length:wordLength)
    if w == 1 {
      sentence.append(word.capitalized)
    } else {
      sentence.append(word)
    }
    if w != wordCount {
      sentence.append(" ")
    } else {
      sentence.append(".")
    }
  }
  return sentence
}

func randomAlphaString(length: Int) -> String {
  srandom(UInt32(time(nil)))
  let charactersString = "abcdefghijklmnopqrstuvwxyz"
  let charactersArray: [Character] = Array(charactersString.characters)
  
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
