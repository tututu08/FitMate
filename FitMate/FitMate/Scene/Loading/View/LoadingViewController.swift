//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import Lottie
import SnapKit
import RxSwift
import RxCocoa

class LoadingViewController: BaseViewController {
    
    private let viewModel: LoadingViewModel // ViewModel 의존성 주입
    private let loadingView = LoadingView() // 뷰 객체 생성
    private var hasNavigatedToGame = false
    private let uid: String
    private let matchCode: String
    
    init(uid: String, matchCode: String) {
        // ViewModel 의존성 주입을 통해 운동 경기 코드를 전달
        self.uid = uid
        self.matchCode = matchCode
        //self.viewModel = LoadingViewModel(matchCode: matchCode)
        self.viewModel = LoadingViewModel(matchCode: matchCode, myUid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = loadingView
        
        // 취소 버튼 Rx 바인딩
        loadingView.cancelButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return Observable.just(false) }
                return self.presentCancelingAlert()
            }
            .filter { $0 }
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                // 1. match 문서 fetch해서 상대방 uid 알아내기
                return FirestoreService.shared
                    .fetchDocument(collectionName: "matches", documentName: self.matchCode)
                    .asObservable()
                    .flatMap { data -> Observable<Void> in
                        guard let inviterUid = data["inviterUid"] as? String,
                              let inviteeUid = data["inviteeUid"] as? String else {
                            return Observable.empty()
                        }
                        let myUid = self.uid
                        let otherUid = (myUid == inviterUid) ? inviteeUid : inviterUid
                        // matchStatus + players 모두 canceled로 갱신
                        return FirestoreService.shared
                            .updateDocument(
                                collectionName: "matches",
                                documentName: self.matchCode,
                                fields: [
                                    "matchStatus": "canceled",
                                    "players.\(myUid).status": "canceled",
                                    "players.\(otherUid).status": "canceled"
                                ]
                            )
                            .asObservable()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.popToTabBar()
            }, onError: { [weak self] error in
                let errorAlert = UIAlertController(
                    title: "에러",
                    message: "매칭 취소에 실패했습니다.\n다시 시도해주세요.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(errorAlert, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 꼭 직접 호출!
        bindViewModel()
    }
    
    
    // 네비게이션 영역 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.hidesBottomBarWhenPushed = true
    }
    
    /// ViewModel 바인딩
    override func bindViewModel() {
        super.bindViewModel()
        
        viewModel.matchStatusEvent
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] status in
                print("받은 상태: \(status)")
                guard let self else { return }
                
                // started 상태가 되면 시작
                if status == "started" && !self.hasNavigatedToGame {
                    print("동시에 시작 조건 충족 → 게임화면 이동")
                    self.hasNavigatedToGame = true
                    
                    // 실시간 감지 리스너 종료
                    MatchEventService.shared.stopMatchListening()
                    self.goToGameScreen()
                } else if status == "rejected" {
                    self.presentRejectedAlert(message: "")
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 게임 화면으로 이동하는 메서드
    private func goToGameScreen() {
        FirestoreService.shared.fetchDocument(collectionName: "matches", documentName: self.matchCode)
            .flatMap { data -> Single<(String, String, String, String, Int)> in
                guard let goalValue = data["goalValue"] as? Int,
                      let inviterUid = data["inviterUid"] as? String,
                      let inviteeUid = data["inviteeUid"] as? String,
                      let exerciseType = data["exerciseType"] as? String,
                      let mode = data["mode"] as? String else {
                    return .error(NSError(domain: "DataError", code: -1, userInfo: nil))
                }
                return .just((inviterUid, inviteeUid, exerciseType, mode, goalValue))
            }
            .flatMap { inviterUid, inviteeUid, exerciseType, mode, goalValue -> Single<(String, String, String, String, Int, String, Bool)> in
                let mateUid = self.uid == inviterUid ? inviteeUid : inviterUid
                let isInviter = self.uid == inviterUid
                
                // 내 아바타
                guard let myAvatarRaw = AvatarManager.shared.selectedAvatarRelay.value?.rawValue else {
                    return .error(NSError(domain: "AvatarError", code: -2, userInfo: [NSLocalizedDescriptionKey: "내 아바타 없음"]))
                }
                
                // 상대 아바타 불러오기
                return FirestoreService.shared.loadSelectedAvatar(uid: mateUid)
                    .map { mateAvatarType in
                        let mateAvatarRaw = mateAvatarType?.rawValue ?? "kaepy" // fallback
                        return (exerciseType, mode, myAvatarRaw, mateAvatarRaw, goalValue, mateUid, isInviter)
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { exerciseType, mode, myCharacter, mateCharacter, goalValue, mateUid, isInviter in
                let matchCode = self.matchCode
                let myUid = self.uid
                
                let pushVC: UIViewController?
                
                // 중복되는 인자를 하나로 묶어서 간소화
                let matchInfo = MatchInfo(
                    matchCode: matchCode,
                    myUid: myUid,
                    mateUid: mateUid,
                    myCharacter: myCharacter,
                    mateCharacter: mateCharacter
                )
                
                if mode == "battle" {
                    switch exerciseType {
                    case "걷기", "달리기", "자전거":
                        pushVC = RunningBattleViewController(
                            exerciseType: exerciseType,
                            goalDistance: goalValue,
                            matchInfo: matchInfo
                        )
                    case "줄넘기":
                        pushVC = JumpRopeBattleViewController(
                            goalCount: goalValue,
                            matchInfo: matchInfo
                        )
                    default: return
                    }
                } else {
                    switch exerciseType {
                    case "걷기", "달리기", "자전거":
                        pushVC = RunningCoopViewController(
                            exerciseType: exerciseType,
                            goalDistance: goalValue,
                            matchInfo: matchInfo
                        )
                    case "플랭크":
                        pushVC = PlankCoopViewController(
                            goalMinutes: goalValue,
                            isInviter: isInviter,
                            matchInfo: matchInfo
                        )
                    case "줄넘기":
                        pushVC = JumpRopeCoopViewController(
                            goalCount: goalValue,
                            matchInfo: matchInfo
                        )
                    default: return
                    }
                }
                
                if let vc = pushVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }, onFailure: { error in
                print("아바타 에러: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    /// 운동 요청 거절 시, 띄워지는 알림창 메서드
    private func presentRejectedAlert(message: String) {
        let alert = CustomAlertViewController(alertType: .matchingFail(message: message))
        alert.onConfirm = { [weak self] in
            self?.popToTabBar()
        }
        UIApplication.topViewController()?.present(alert, animated: true)
        return
        
    }
    
    func presentCancelingAlert() -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            let alert = UIAlertController(
                title: "매칭 취소",
                message: "정말 운동을 취소하시겠습니까?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: { _ in
                observer.onNext(false)
                observer.onCompleted()
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: { _ in
                observer.onNext(true)
                observer.onCompleted()
            }))
            self.present(alert, animated: true)
            return Disposables.create()
        }
    }
    
    deinit {
        print("LoadingViewController deinit")
    }
    
}
