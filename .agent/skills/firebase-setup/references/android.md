# Android Setup for Firebase

## 1. google-services.json

`flutterfire configure`가 자동으로 `android/app/google-services.json` 위치에 생성합니다.
수동으로 배치할 경우 정확히 `android/app/` 디렉터리에 있어야 합니다.

## 2. build.gradle 설정 (필요시)

FlutterFire CLI가 대부분 자동으로 처리하지만, 빌드 에러 발생 시 확인하세요.

### android/build.gradle (Project-level)
```gradle
buildscript {
    dependencies {
        // google-services 플러그인 확인
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### android/app/build.gradle (App-level)
```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services' // 필수

android {
    defaultConfig {
        // MultiDex가 필요한 경우 (메소드 수 초과 시)
        multiDexEnabled true
        minSdkVersion 23 // Firebase 최신 버전은 21 이상 권장
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:33.7.0')
}
```
