//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController {
    
    let viewModel = LoginViewModel() // 뷰모델
    let googleLoginTrigger = PublishRelay<Void>() // 로그인 버튼 클릭 이벤트 전달
    let nextViewRelay = PublishRelay<Void>() // 다음 버튼 클릭 이벤트 전달
    
    let logInView = LoginView()
    
    override func loadView() {
        super.loadView()
        self.view = logInView
    }
    
    // 네비게이션 영역 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindButton()
    }
    /// 버튼 이벤트를 ViewModel로 전달
    private func bindButton() {
        self.logInView.googleLogin.rx.tap
            // UI에서 발생한 이벤트를 Relay로 보내는 상황
            .bind(to: googleLoginTrigger) // relay에 이벤트(빈 값)를 흘려보내라
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        // 명시적인 흐름과 불변성(immutable)을 유지하기 위해서 이래와 같이 선언
        let input = LoginViewModel.Input(
            // ViewModel 에서 값을 방출하지 못하게 막기위해 asObservable 사용
            // asObservable : 뷰 모델에 구독만 가능하게 변환
            // 이렇게 되면 값을 방출 할 수 없음,
            //.subscribe()는 가능
            //.onNext(), .accpet()로 값을 방출하는건 불가능
            googleLoginTrigger: googleLoginTrigger.asObservable()
        )
        
        let output = viewModel.transform(input: input, presentingVC: self)
        
        output.navigation
            .drive(onNext: { [weak self] nav in
                // ViewModel에서 전달한 목적에 따라 화면 이동만 수행
                switch nav {
                case .goToMainViewController(let uid):
                    // SceneDelegate를 가져오기
                    // UIApplication.shared.connectedScenes는 현재 앱의 모든 Scene을 반환
                    // first?.delegate는 첫 번째 Scene의 delegate를 가져옴
                    //as? SceneDelegate로 다운캐스팅하여 window 속성에 접근
                    guard let sceneDelegate = UIApplication.shared.connectedScenes
                        .first?.delegate as? SceneDelegate else { return }
                    
                    // 로그인 이후 메인으로 쓸 TabBarController 생성
                    let tabBarController = TabBarController(uid: uid) // 로그인 후 메인화면
                    
                    // SceneDelegate 의 window 없는지 확인
                    guard let window = sceneDelegate.window else { return }
                    
                    // 화면 전환
                    UIView.transition(with: window,
                                      duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        sceneDelegate.window?.rootViewController = tabBarController
                    })
                case .goToInputMateCode(let uid):
                    // 닉네임만 있음, 메이트 없음 → 메이트코드 입력
                    let vc = CodeShareViewController(uid: uid)
                    self?.navigationController?.pushViewController(vc, animated: true)
                case .goToInputNickName(let uid):
                    // 닉네임이 없음 → 닉네임 입력
                    let vc = NicknameViewController(uid: uid)
                    self?.navigationController?.pushViewController(vc, animated: true)

                case .error(let msg):
                    // 에러 발생 시 메시지 띄우기
                    self?.showErrorAlert(message: msg)
                }
            }).disposed(by: disposeBag)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
