/// Version
/// RxSwift: 6.6.0
/// RxCocoa: 6.6.0

/// Usage Rules

/// [API 호출 관련]
/// - Firebase Firestore, Auth 연동 시 → Single 사용 (1회성 응답)
/// - 실시간 업데이트 (ex: snapshot listener) 시 → Observable 사용 가능 (팀 내 명확히 주석 작성)

/// [UI 바인딩 관련]
/// - ViewModel → View 바인딩 시 → BehaviorRelay / PublishRelay 사용
/// - Driver 사용 가능 (UI 안전성 보장 시 사용, 팀 내 합의 후 적용)
/// - Observable → UI 바인딩 직접 사용 지양 (Relay 또는 Driver로 변환해서 사용)

/// [DisposeBag 관리]
/// - ViewModel 내에서 disposeBag 직접 관리
/// - ViewController에는 BaseViewController의 disposeBag 사용
/// - Global DisposeBag 사용 금지

/// [Subject 사용 규칙]
/// - Observable / Subject 혼용 금지
/// - PublishSubject 사용 금지 (Relay로 대체)
/// - BehaviorSubject는 특별한 경우 외 사용 금지 → 기본은 BehaviorRelay 사용

/// [Observable.create 사용 규칙]
/// - Observable.create 사용 시 반드시 주석 작성 (이유 및 사용 목적 명시)
/// - 불필요한 create 사용 금지 (기본적으로 FirebaseService 등의 래퍼 활용 우선)

/// [기타]
/// - ViewModel Input / Output 구조 통일해서 사용
/// - Rx 코드가 섞여 복잡한 경우 → 별도 함수로 분리
/// - API 호출 후 상태 업데이트 → 명확한 상태 관리 (isLoading 등) → Relay 사용 추천
