//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: BaseViewController {
    
    // ViewModel 객체 생성
    private let viewModel: MainViewModel
    
    // MatchAcceptViewModel 객체 생성
    // 역할 : 운동 경기 수락 여부에 따른 운동 경기 상태(matchStatus) 변경 ViewModel
    private let matchAcceptViewModel = MatchAcceptViewModel()
    
    let mainView = MainView()
    
    // 로그인 유저의 uid
    private let uid: String
    
    // 초기화 함수
    init(uid: String) {
        self.uid = uid // 의존성 주입
        self.viewModel = MainViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainView
        FirestoreService.shared.fetchDocument(collectionName: "users", documentName: self.uid)
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                
                if let myNickname = data["nickname"] as? String,
                   let mate = data["mate"] as? [String: Any],
                   let mateNickname = mate["nickname"] as? String {
                    self.mainView.changeAvatarLayout(hasMate: true, myNickname: myNickname, mateNickname: mateNickname)
                }
            }).disposed(by: disposeBag)
        
        navigationItem.backButtonTitle = ""
    }
    
    // 네비게이션 영역 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    // 네비게이션 영역 다시 보여줌
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func bindViewModel() {
        /// 뷰모델에 전달할 입력 정의
        let input = MainViewModel.Input(
            exerciseTap: mainView.exerciseButton.rx.tap.asObservable(),
            mateAvatarTap: mainView.mateAvatarImage.rx.tap
        )

        ///  transform 통해 output 정의
        let output = viewModel.transform(input: input)

        /// 메이트가 없을 때 → 커스텀 얼럿 띄우기
        output.hasNoMate
            .drive(onNext: { [weak self] in
                guard let self else { return }
                let alertVC = HasNoMateViewController(uid: self.uid)
                alertVC.modalPresentationStyle = .overFullScreen
                self.present(alertVC, animated: false)
            })
            .disposed(by: disposeBag)

        /// 메이트가 있을 때 → 운동 선택 화면 이동
        output.moveToExercise
            .drive(onNext: { [weak self] in
                guard let self else { return }
                let selectSports = SportsSelectionViewController(uid: self.uid)
                selectSports.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(selectSports, animated: true)
            })
            .disposed(by: disposeBag)

        /// 운동 초대 수신 → alert 띄우기
        output.showMatchEvent
            .drive(onNext: { [weak self] matchCode in
                self?.presentAlertForMatch(matchCode: matchCode)
            })
            .disposed(by: disposeBag)
        
        output.moveToMatePage
            .drive(onNext: { [weak self] mateUid in
                guard let self else { return }
                let vc = MatepageViewController(mateUid: mateUid)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }

    /// 운동 초대 알림창 띄우는 메서드
    func presentAlertForMatch(matchCode: String) {
        let alert = UIAlertController(
            title: "운동 메이트 요청",
            message: "운동 초대가 도착했습니다!",
            preferredStyle: .alert
        )
        // 수락
        alert.addAction(UIAlertAction(title: "수락", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            // 수락한 결과를 뷰모델에 보냄
            // matchStatus 값이 accepted 로 변경됨
            self.matchAcceptViewModel.respondToMatch(matchCode: matchCode, myUid: self.uid, accept: true)
            
            // 게임화면으로 이동
            // 아직 테스트용으로 구현됨
//            let gameVC = RunningCoopViewController(goalDistance: 444, myCharacter: "kaepy", mateCharacter: "kaepy")
//            gameVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(gameVC, animated: true)
            
            let gameVC = LoadingViewController(uid: self.uid, matchCode: matchCode)
            gameVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(gameVC, animated: true)
        }))
        // 거절
        alert.addAction(UIAlertAction(title: "거절", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            // 거절한 결과를 뷰모델에 보냄
            // matchStatus 값이 rejected 로 변경됨
            self.matchAcceptViewModel.respondToMatch(matchCode: matchCode, myUid: self.uid, accept: false)
        }))
        present(alert, animated: true)
    }
}

/// UIImageView에 rx.tap 기능 확장
extension Reactive where Base: UIImageView {
    /// UIImageView에 UITapGestureRecognizer를 붙이고
    ///  Void 이벤트를 Observable로 방출
    var tap: Observable<Void> {
        let tapGesture = UITapGestureRecognizer()
        
        base.addGestureRecognizer(tapGesture)
        base.isUserInteractionEnabled = true
        
        return tapGesture.rx.event
            .map { _ in () } // 이벤트 무시하고 Void 반환
            .asObservable()
    }
}
