import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa
import CoreLocation

final class RunningCoopViewController: BaseViewController {
    private let rootView = RunningCoopView()
    private let runningCoopViewModel: RunningCoopViewModel
    private let startRelay = PublishRelay<Void>()
    private let mateDistanceRelay = BehaviorRelay<Double>(value: 0)
    private let goalselecionViewModel = GoalSelectionViewModel()
    private let locationAuthStatusRelay = BehaviorRelay<CLAuthorizationStatus>(value: CLLocationManager.authorizationStatus())

    private let exerciseType: String
    private let goalDistance: Int
    private let matchCode: String
    private let mateUid: String
    private let myUid: String
    private let myCharacter: String
    private let mateCharacter: String
    private let quitRelay = PublishRelay<Void>()
    private let mateQuitRelay = PublishRelay<Void>()
    
    init(exerciseType: String, goalDistance: Int, matchCode: String, myUid: String, mateUid: String, myCharacter: String, mateCharacter: String) {
        self.exerciseType = exerciseType
        self.goalDistance = goalDistance
        self.matchCode = matchCode
        self.myUid = myUid
        self.mateUid = mateUid
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter

        self.runningCoopViewModel = RunningCoopViewModel(
            goalDistance: goalDistance,
            myCharacter: myCharacter,
            mateCharacter: mateCharacter,
            matchCode: matchCode,
            myUid: myUid,
            mateUid: mateUid
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = rootView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.updateGoal("\(exerciseType) \(runningCoopViewModel.goalDistance)Km")
        rootView.updateMyCharacter(runningCoopViewModel.myCharacter)
        rootView.updateMateCharacter(runningCoopViewModel.mateCharacter)

        // 화면 진입 시 권한 상태 체크
        locationAuthStatusRelay.accept(CLLocationManager.authorizationStatus())

        // 앱 포그라운드 복귀 시 권한 상태 체크
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .map { _ in CLLocationManager.authorizationStatus() }
            .bind(to: locationAuthStatusRelay)
            .disposed(by: disposeBag)

        // Firestore로부터 메이트 거리 수신
        FirestoreService.shared
            .observeMateProgress(matchCode: matchCode, mateUid: mateUid)
            .bind(to: mateDistanceRelay)
            .disposed(by: disposeBag)

        startRelay.accept(())
        runningCoopViewModel.bindDistanceFromFirestore()

        rootView.stopButton.rx.tap
            .bind { [weak self] in
                self?.rootView.showQuitAlert(
                    type: .myQuitConfirm,
                    onResume: {},
                    onQuit: { [weak self] in self?.quitRelay.accept(()) }
                )
            }
            .disposed(by: disposeBag)
    }

    override func bindViewModel() {
        super.bindViewModel()

        let input = RunningCoopViewModel.Input(
            startTracking: startRelay.asObservable(),
            mateDistance: mateDistanceRelay.asObservable(),
            quit: quitRelay.asObservable(),
            mateQuit: mateQuitRelay.asObservable(),
            locationAuthStatus: locationAuthStatusRelay.asObservable()
        )

        let output = runningCoopViewModel.transform(input: input)

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

        output.progress
            .drive(onNext: { [weak self] ratio in
                self?.rootView.updateProgress(ratio: ratio)
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

        output.locationAuthDenied
            .emit(onNext: { [weak self] in
                self?.showLocationDeniedAlert()
            })
            .disposed(by: disposeBag)
    }

    private func navigateToFinish(success: Bool, myDistance: Double) {
        let finishVM = FinishViewModel(
            mode: .cooperation,
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
        runningCoopViewModel.stopLocationUpdates()

        rootView.showQuitAlert(
            type: .mateQuit,
            onBack: { [weak self] in
                self?.runningCoopViewModel.finish(success: false)
                self?.navigateToFinish(success: false, myDistance: self?.runningCoopViewModel.myDistanceDisplayRelay.value ?? 0.0)
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
