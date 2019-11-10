# Otofuda-iOS

<img src="https://i.gyazo.com/780ef47d72899d0609cc755c21435b2b.png" width="30%" height="auto">

## Getting Started

1. CocoaPodをインストールしてください。
```
pod install
```

2. Carthageをインストールしてください。
```
carthage update --platform iOS
```

3. 下記URLから `GoogleService-Info.plist` を追加してください

[Firebase/Settings](https://console.firebase.google.com/project/otofuda-a41cc/settings/general/ios:nkmr-lab.Otofuda-iOS)

## Installing

### Carthage
- Alamofire/Alamofire
- Alamofire/AlamofireImage
- SwiftyJSON/SwiftyJSON
- mxcl/PromiseKit
- Hearst-DD/ObjectMapper

### Pods
- Firebase
- Firebase/Database

## Rest API
- GET https://uniotto.org/api/get_otofuda_list.php?id={id}
- GET https://uniotto.org/api/get_rand16_itunes.php?id={id}
- GET https://uniotto.org/api/get_all_otofuda_list.php

## Architecture
- MVVM

## Milestone
- v1.0.0 https://github.com/nkmr-lab/Otofuda-iOS/projects/1
- v1.0.1 https://github.com/nkmr-lab/Otofuda-iOS/projects/2
