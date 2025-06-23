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
        
        navigationItem.backButtonTitle = ""
    }
    
    // 네비게이션 영역 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        fetchMateStatusAndUpdateUI()
    }
    
    // 네비게이션 영역 다시 보여줌
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func fetchMateStatusAndUpdateUI() {
        mainView.alpha = 0
        
        FirestoreService.shared.fetchDocument(collectionName: "users", documentName: uid)
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }

                let hasMate = data["hasMate"] as? Bool ?? false
                let myNickname = data["nickname"] as? String ?? "나"

                if hasMate,
                   let mate = data["mate"] as? [String: Any],
                   let mateNickname = mate["nickname"] as? String {
                    self.mainView.changeAvatarLayout(hasMate: true, myNickname: myNickname, mateNickname: mateNickname)
                    UIView.animate(withDuration: 0.2) {
                        self.mainView.alpha = 1
                    }
                } else {
                    self.mainView.changeAvatarLayout(hasMate: false, myNickname: myNickname, mateNickname: "")
                    UIView.animate(withDuration: 0.2) {
                        self.mainView.alpha = 1
                    }
                }
            }, onFailure: { error in
                print("메이트 상태 조회 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
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
        
        output.moveToMatePage
            .drive(onNext: { [weak self] mateUid in
                guard let self else { return }
                let vc = MatepageViewController(mateUid: mateUid)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.showMateDisconnected
             .drive(onNext: { [weak self] in
                 self?.presentMateAlert(description: "상대방이 메이트를 종료했습니다.")
             })
             .disposed(by: disposeBag)

         output.showMateWithdrawn
             .drive(onNext: { [weak self] in
                 self?.presentMateAlert(description: "상대방이 회원탈퇴하였습니다.")
             })
             .disposed(by: disposeBag)
    }
    
    private func presentMateAlert(description: String) {
        let popup = PartnerLeftAlertView()
        popup.configure(description: description)
        
        popup.alpha = 0

        // window에 직접 추가하여 어떤 화면에서도 보이도록(현재 활성화된 키 윈도우 가져오기)
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(popup)
            popup.snp.makeConstraints { $0.edges.equalToSuperview() }
            
            // fade-in 애니메이션 실행
            UIView.animate(withDuration: 0.25) {
                popup.alpha = 1
            }

            popup.confirmButton.rx.tap
                .bind { [weak self, weak popup] in
                    guard let self, let popup else { return }
                    
                    // fade-out 애니메이션 실행
                    UIView.animate(withDuration: 0.2, animations: {
                        popup.alpha = 0
                    }) { _ in
                        popup.removeFromSuperview()
                        self.cleanupMateAndRefresh()
                    }
                }
                .disposed(by: disposeBag)
        }
    }

    // Firestore 메이트 정보 삭제 → UI 갱신
    private func cleanupMateAndRefresh() {
        FirestoreService.shared.deleteMate(myUid: uid)
            .subscribe(onSuccess: { [weak self] in
                self?.fetchMateStatusAndUpdateUI()
            }, onFailure: { error in
                print("삭제 실패:", error.localizedDescription)
            })
            .disposed(by: disposeBag)
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
