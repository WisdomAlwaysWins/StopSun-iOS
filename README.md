<p align="center">
  <img width="100" height="100" alt="Image" src="https://github.com/user-attachments/assets/3c788747-b220-466d-a19a-a5a5dde17c1f" />
</p>
<h1 align="center">그만해 · StopSun ☀️</h1>
<p align="center">
  <strong>Apple Developer Academy @ POSTECH · 5인 팀 프로젝트</strong><br/>
  실시간 자외선 노출 추적 앱 — 개인 기여 기록
</p>
<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-black?logo=apple" />
  <img src="https://img.shields.io/badge/watchOS-10.0+-black?logo=apple" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift" />
  <img src="https://img.shields.io/badge/SwiftUI-blue" />
</p>

</br>

<p>
  <img width="15%" alt="Image" src="https://github.com/user-attachments/assets/98adede1-7e2a-4792-800d-77c8dd4d60a4" />  
  <img width="15%" alt="Image" src="https://github.com/user-attachments/assets/284c1b19-1bfc-48d2-8d03-220ed1e6f1e7" />
  <img width="15%" alt="Image" src="https://github.com/user-attachments/assets/1064d600-1ec9-4668-8be6-7b7ea4597078" />
  <img width="15%" alt="Image" src="https://github.com/user-attachments/assets/6556d79c-b247-4c3b-94e2-bae62d84777d" />
  <img width="15%" alt="Image" src="https://github.com/user-attachments/assets/b7e2e10d-0ceb-473b-a3cf-cc19c53ea4bf" />
  <img width="15%" alt="Image" src="https://github.com/user-attachments/assets/999db274-329d-49d9-b7ea-0423d655daf4" />
</p>

> 🔗 팀 원본 저장소: [XCode-Blue/StopSun-iOS](https://github.com/XCode-Blue/StopSun-iOS)

---

## 담당 역할

3인 iOS 개발팀에서 **Apple Watch UI 설계 및 구현**을 담당했고, 앱 전체의 **의존성 주입 구조 설계 · 프로토콜 추상화 · 유닛 테스트 작성**을 주도했습니다.

## 주요 기여

### 1. DIContainer — 의존성 주입 구조 설계

모든 Manager 인스턴스를 한 곳에서 생성하고 주입하는 `DIContainer`를 설계했습니다. Production과 Preview 환경을 분리해, SwiftUI Preview에서도 Mock 객체만으로 UI 확인이 가능합니다.

```swift
// 프로덕션
DIContainer.shared.makeDashboardViewModel()

// Preview / 테스트 — Mock으로 교체
DIContainer.preview.makeDashboardViewModel()
```

---

### 2. SyncCoordinator — 데이터 흐름 중앙화

HealthKit, WeatherKit, Location, WatchConnectivity, LiveActivity 등 여러 Manager가 서로 연관된 상태를 가지고 있어 데이터 흐름이 복잡했습니다. ViewModel이 각 Manager를 직접 호출하는 대신, `SyncCoordinator`가 모든 데이터 흐름을 조율하도록 설계했습니다.

```
HealthKit ──┐
WeatherKit ─┤──▶ SyncCoordinator ──▶ ViewModel ──▶ View
Location ───┘         │
                       ├──▶ WatchConnectivity ──▶ Apple Watch
                       └──▶ LiveActivity ──▶ Dynamic Island
```

주요 설계 결정:
- `@Observable` + `@MainActor` — 상태 변경이 항상 메인 스레드에서 이루어지도록 보장
- NotificationCenter 기반 이벤트 처리 — HealthKit 백그라운드 딜리버리, 위치 변경, 자정 리셋
- 증분 SED 계산 — 매 동기화 시 전체 기록을 재계산하지 않고, 미처리 HealthKit 레코드만 처리

---

### 3. Protocol 레이어 — 테스트 가능한 구조

모든 Manager에 Protocol을 추가해 테스트 시 Mock으로 완전히 교체할 수 있도록 했습니다.

```swift
// 실제
let healthKit: any HealthKitManagerProtocol = HealthKitManager()

// 테스트
let healthKit: any HealthKitManagerProtocol = MockHealthKitManager()
```

---

### 4. Apple Watch UI 설계 및 구현

Watch 앱 UI를 처음부터 설계하고 구현했습니다.

- 선크림 타이머 카운트다운 화면
- UV 경고 레벨에 따른 색상 상태 표시

---

## 기여 범위 요약

```
Core/
├── DIContainer.swift       ← 설계 및 구현
├── AppError.swift          ← 설계 및 구현
└── ErrorHandler.swift      ← 설계 및 구현

Managers/
├── SyncCoordinator.swift   ← 설계 및 구현
├── Protocols/              ← 전체 프로토콜 추가
└── Mocks/                  ← 전체 Mock의 프켈레톤 코드 작성

StopSunWatch Watch App/     ← UI 설계 및 구현
StopSunTests/               ← 일부 테스트 작성
```

---

## 기술 스택

| 분류 | 스택 |
|---|---|
| UI | SwiftUI |
| Apple 프레임워크 | HealthKit, Core Location, WatchKit, WatchConnectivity, ActivityKit |
| 아키텍처 | MVVM, DIContainer, Protocol 기반 의존성 주입 |



