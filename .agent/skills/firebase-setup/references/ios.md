# iOS Setup for Firebase

## 1. 사전 요구사항 (Prerequisites)

- **CocoaPods**: 최신 버전 유지 (`sudo gem install cocoapods`)
- **Xcode**: 최신 버전 권장
- **Ruby Gem `xcodeproj`**: `flutterfire configure` 실행 시 필요할 수 있음

```bash
gem install xcodeproj --user-install
```

## 2. Podfile 설정

Firebase 패키지는 최신 iOS 버전을 요구할 수 있습니다. `ios/Podfile`을 확인하고 필요시 버전을 올리세요.

```ruby
platform :ios, '15.0' # 14.0 이상 권장
```

만약 `pod install` 중 에러가 발생하면 `ios` 폴더에서 다음을 실행하세요:

```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

## 3. GoogleService-Info.plist

`flutterfire configure`가 자동으로 생성해주지만, 만약 실패한다면:
1. Firebase Console에서 `GoogleService-Info.plist` 다운로드
2. Xcode를 열고 `Runner` 프로젝트의 `Runner` 그룹 안에 파일을 드래그 앤 드롭
3. **Target Membership**에서 `Runner` 체크 확인
