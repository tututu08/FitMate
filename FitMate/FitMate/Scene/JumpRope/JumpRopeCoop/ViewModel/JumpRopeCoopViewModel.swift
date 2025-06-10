//
//  JumpRopeCoopViewModel.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation
import CoreMotion
import RxSwift
import RxCocoa

/// ViewModel that counts jump rope motions using CoreMotion.
final class JumpRopeCoopViewModel: ViewModelType {

    struct Input {
        /// Trigger to start counting.
        let start: Observable<Void>
        /// Mate's current count updates.
        let mateCount: Observable<Int>
    }

    struct Output {
        let myCountText: Driver<String>
        let mateCountText: Driver<String>
        let progress: Driver<CGFloat>
    }

    private let motionManager = CMMotionManager()
    private let disposeBag = DisposeBag()

    private let myCountRelay = BehaviorRelay<Int>(value: 0)
    private let mateCountRelay = BehaviorRelay<Int>(value: 0)

    /// 협력 진행률 계산을 위한 목표 카운트
    private let goalCount: Int

    /// - Parameter goalCount: 사용자가 설정한 목표 카운트
    init(goalCount: Int) {
        self.goalCount = goalCount
    }

    func transform(input: Input) -> Output {
        input.start
            .subscribe(onNext: { [weak self] in
                self?.startAccelerometer()
            })
            .disposed(by: disposeBag)

        input.mateCount
            .bind(to: mateCountRelay)
            .disposed(by: disposeBag)

        let myText = myCountRelay
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        let mateText = mateCountRelay
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        let progress = Observable.combineLatest(myCountRelay, mateCountRelay) { [weak self] my, mate -> CGFloat in
            guard let self else { return 0 }
            return CGFloat(min(1, Float(my + mate) / Float(self.goalCount)))
        }
        .asDriver(onErrorJustReturn: 0)

        return Output(myCountText: myText, mateCountText: mateText, progress: progress)
    }

    private var count = 0
    private var canCount = true
    private let accelerationLimit = 1.85
    private let cooldown = 0.45

    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data = data else { return }
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let speed = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))

            if speed > self.accelerationLimit && self.canCount {
                self.count += 1
                self.myCountRelay.accept(self.count)
                self.canCount = false
                DispatchQueue.main.asyncAfter(deadline: .now() + self.cooldown) { [weak self] in
                    self?.canCount = true
                }
            }
        }
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
