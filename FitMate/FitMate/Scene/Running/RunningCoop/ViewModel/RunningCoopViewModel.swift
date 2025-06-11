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
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager() // 위치 정보 추적 CLLocationManager()
    private var totalDistance: CLLocationDistance = 0 // 총 이동 거리 저장
    private var previousLocation: CLLocation? // 이전 위치 저장
    
    struct Input {
        let selectedGoalRelay: Observable<String>
    }
    
    struct Output {
        let distanceText: Driver<String>
    }
    
    private let distanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    
    func transform(input: Input) -> Output {
        
        
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.startUpdatingLocation()
        
        locationManager.rx.didUpdateLocations
            .compactMap { $0.last }
            .filter { $0.horizontalAccuracy < 20 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newLocation in
                guard let self = self else { return }
                
                if let lastLocation = self.previousLocation {
                    let distance = newLocation.distance(from: lastLocation)
                    self.totalDistance += distance
                    
                    let formattedDistance = String(format: "%.1f", self.totalDistance)
                    self.distanceTextRelay.accept(formattedDistance + "m")
                }
                self.previousLocation = newLocation
            })
            .disposed(by: disposeBag)
        
        return Output(distanceText: distanceTextRelay.asDriver())
    }
    
    
}
