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
    private let viewModel = MainViewModel()
    
    // MatchAcceptViewModel 객체 생성
    // 역할 : 운동 경기 수락 여부에 따른 운동 경기 상태(matchStatus) 변경 ViewModel
    private let matchAcceptViewModel = MatchAcceptViewModel()
    
    private let mainView = MainView()
    
    // 로그인 유저의 uid
    private let uid: String
    
    // 초기화 함수
    init(uid: String) {
        self.uid = uid // 의존성 주입
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
        mainView.exerciseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let SportsSelectionVC = SportsSelectionViewController(uid: self.uid)
                SportsSelectionVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(SportsSelectionVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 운동 초대 감지
        viewModel.matchEvent
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] matchCode in
                self?.presentAlertForMatch(matchCode: matchCode)
                
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
            let gameVC = RunningCoopViewController(
                    goalDistance: 1000,
                    myCharacter: "morano",
                    mateCharacter: "mora"
                )
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
