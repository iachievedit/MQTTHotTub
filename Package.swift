import PackageDescription

let package = Package(
    name: "MQTTHotTub",
    dependencies:[
      .Package(url:"https://github.com/iachievedit/MQTT", majorVersion:0),
      .Package(url:"https://github.com/Zewo/JSON",   majorVersion: 0)
    ]
)
