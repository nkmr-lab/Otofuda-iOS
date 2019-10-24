# Otofuda-iOS

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

## Branchs
- `master` リリースするタイミングでマージする
- `develop` 各機能が完成したらマージする
- `features/xxxx(機能名)` 機能ごとでブランチを分ける

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

## Commit Message Rule
### Emoji Prefix
|Type|Emoji|
|---|:---:|
|初めてのコミット（Initial Commit）|	🎉|
|バージョンタグ（Version Tag）|	🔖|
|新機能（New Feature）|	✨|
|バグ修正（Bugfix）|	🐛|
|フォルダ移動など（Folder）|	📁|
|リファクタリング(Refactoring)|	♻️|
|ドキュメント（Documentation）|	📚|
|デザインUI/UX(Accessibility)|	🎨|
|パフォーマンス（Performance）	|🐎|
|ツール（Tooling）|	🔧|
|テスト（Tests）	|🚨|
|非推奨追加（Deprecation）|	💩|
|削除（Removal）|	🗑️|
|WIP(Work In Progress)|	🚧|
