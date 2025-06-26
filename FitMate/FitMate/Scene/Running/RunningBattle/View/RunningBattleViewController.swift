import RxSwift
import UIKit
import Foundation
import RxCocoa
import CoreLocation

class RunningBattleViewController: BaseViewController {

    private let rootView = RunningBattleView()
    private let viewModel: RunningBattleViewModel

    private let startTrriger = PublishRelay<Void>()
    private let quitRelay = PublishRelay<Void>()
    private let mateQuitRelay = PublishRelay<Void>()
    private let mateDistanceRelay = PublishRelay<Double>()
    private let locationAuthStatusRelay = BehaviorRelay<CLAuthorizationStatus>(value: CLLocationManager.authorizationStatus())

    private let exerciseType: String
    private let goalDistance: Int
    private let matchCode: String
    private let mateUid: String
    private let myUid: String
    private let myCharacter: String
    private let mateCharacter: String

    init(exerciseType: String, goalDistance: Int, matchCode: String, myUid: String, mateUid: String, myCharacter: String, mateCharacter: String) {
        self.exerciseType = exerciseType
        self.goalDistance = goalDistance
        self.matchCode = matchCode
        self.myUid = myUid
        self.mateUid = mateUid
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.viewModel = RunningBattleViewModel(
            goalDistance: goalDistance,
            myCharacter: myCharacter,
            mateCharacter: mateCharacter,
            matchCode: matchCode,
            myUid: myUid
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("not implemented") }

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.updateGoal("\(exerciseType) \(viewModel.goalDistance)Km")
        rootView.updateMyCharacter(myCharacter)
        rootView.updateMateCharacter(mateCharacter)

        // 앱 포그라운드 복귀 시 권한 상태 체크
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .map { _ in CLLocationManager.authorizationStatus() }
            .bind(to: locationAuthStatusRelay)
            .disposed(by: disposeBag)

        FirestoreService.shared
            .observeMateProgress(matchCode: matchCode, mateUid: mateUid)
            .bind(to: mateDistanceRelay)
            .disposed(by: disposeBag)

        startTrriger.accept(())

        rootView.stopButton.rx.tap
            .bind { [weak self] in
                self?.rootView.showQuitAlert(
                    type: .myQuitConfirm,
                    onResume: {},
                    onQuit: { [weak self] in
                        self?.quitRelay.accept(())
                    }
                )
            }
            .disposed(by: disposeBag)
    }

    override func bindViewModel() {
        super.bindViewModel()

        let input = RunningBattleViewModel.Input(
            startTracking: startTrriger.asObservable(),
            mateDistance: mateDistanceRelay.asObservable(),
            quit: quitRelay.asObservable(),
            mateQuit: mateQuitRelay.asObservable(),
            locationAuthStatus: locationAuthStatusRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.myDistanceText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateMyRecord(text)
            })
            .disposed(by: disposeBag)

        output.mateDistanceText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateMateRecord(text)
            })
            .disposed(by: disposeBag)

        output.myProgress
            .drive(onNext: { [weak self] progress in
                self?.rootView.myUpdateProgress(ratio: progress)
            })
            .disposed(by: disposeBag)

        output.mateProgress
            .drive(onNext: { [weak self] progress in
                self?.rootView.mateUpdateProgress(ratio: progress)
            })
            .disposed(by: disposeBag)

        output.didFinish
            .emit(onNext: { [weak self] (success, myDistance) in
                self?.navigateToFinish(success: success, myDistance: myDistance)
            })
            .disposed(by: disposeBag)

        output.mateQuitEvent
            .emit(onNext: { [weak self] in
                self?.receiveMateQuit()
            })
            .disposed(by: disposeBag)

        // 위치 권한 거절 시 알림
        output.locationAuthDenied
            .emit(onNext: { [weak self] in
                self?.showLocationDeniedAlert()
            })
            .disposed(by: disposeBag)
    }

    private func navigateToFinish(success: Bool, myDistance: Double) {
        let finishVM = FinishViewModel(
            mode: .battle,
            sport: exerciseType,
            goal: goalDistance,
            goalUnit: "Km",
            myDistance: myDistance,
            character: myCharacter,
            success: success
        )
        let vc = FinishViewController(
            uid: myUid,
            mateUid: mateUid,
            matchCode: matchCode,
            viewModel: finishVM
        )
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    func receiveMateQuit() {
        viewModel.stopLocationUpdates()
        rootView.showQuitAlert(
            type: .mateQuit,
            onBack: { [weak self] in
                self?.viewModel.finish(success: true)
                self?.navigateToFinish(success: true, myDistance: self?.viewModel.myDistanceRelay.value ?? 0.0)
            }
        )
    }

    private func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "위치 권한 필요",
            message: "운동 기록을 위해 위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }))

        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { [weak self] _ in
            guard let self = self else { return }
            FirestoreService.shared
                .updateMatchStatus(matchCode: self.matchCode, status: "cancelLocation")
                .subscribe(
                    onCompleted: {
                        print("matchStatus: cancelLocation 저장 완료")
                    },
                    onError: { error in
                        print("matchStatus 업데이트 실패: \(error.localizedDescription)")
                    }
                )
                .disposed(by: self.disposeBag)
        }))

        present(alert, animated: true)
    }


}
