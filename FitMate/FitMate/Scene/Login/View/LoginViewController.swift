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
                case .goToSeleteSport(let uid):
                    let vc = SportsSelectionViewController(uid: uid)
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
