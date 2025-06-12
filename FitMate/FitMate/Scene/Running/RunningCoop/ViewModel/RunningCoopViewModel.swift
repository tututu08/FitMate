//
//  RunningViewModel.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import RxSwift
import CoreLocation
import RxCoreLocation
import RxCocoa

class RunningCoopViewModel: ViewModelType {
    private let disposeBag = DisposeBag() // Rx 구독 해제를 위한 DisposeBag
    private let locationManager = CLLocationManager() // 위치 추적을 위한 CLLocationManager 인스턴스
    private var totalDistance: CLLocationDistance = 0 // 총 이동 거리 저장 변수
    private var previousLocation: CLLocation? // 이전 위치 저장 변수
    
    // ViewModel의 Input 구조체
    struct Input {
        let selectedGoalRelay: Observable<String> // 사용자가 설정한 목표
    }
    
    // ViewModel의 Output 구조체
    struct Output {
        let distanceText: Driver<String> // 총 이동 거리 텍스트 형식으로 출력
    }
    
    // 거리 텍스트를 저장하는 BehaviorRelay, 초기값은 "0.0 m"
    private let distanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    
    // transform 메서드
    func transform(input: Input) -> Output {
        
        // 위치 권한 요청
        locationManager.requestWhenInUseAuthorization()
        // 위치 정확도 설정 (가장 정확하게)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 활동 유형 설정 (피트니스 활동으로 설정)
        locationManager.activityType = .fitness
        // 위치 업데이트 시작
        locationManager.startUpdatingLocation()
        
        // 위치가 업데이트될 때마다 처리
        locationManager.rx.didUpdateLocations
            .compactMap { $0.last } // 가장 최근 위치만 사용
            .filter { $0.horizontalAccuracy < 20 } // 정확도가 20m 미만일 때만 사용
            .observe(on: MainScheduler.instance) // UI 업데이트를 위해 메인 스레드에서 관찰
            .subscribe(onNext: { [weak self] newLocation in
                guard let self = self else { return }
                
                // 이전 위치가 있다면 거리 계산
                if let lastLocation = self.previousLocation {
                    let distance = newLocation.distance(from: lastLocation) // 두 위치 간 거리 계산
                    self.totalDistance += distance // 총 거리 누적
                    
                    // 거리 소수점 1자리까지 포맷팅 후 Relay에 저장
                    let formattedDistance = String(format: "%.1f", self.totalDistance)
                    self.distanceTextRelay.accept(formattedDistance + "m")
                }
                
                // 현재 위치를 이전 위치로 저장 (다음 거리 계산을 위해)
                self.previousLocation = newLocation
            })
            .disposed(by: disposeBag) // 메모리 누수 방지를 위한 dispose 처리
        
        // Output으로 거리 텍스트 Relay를 Driver로 변환하여 반환
        return Output(distanceText: distanceTextRelay.asDriver())
    }
}
