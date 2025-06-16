//
//  LoginViewController.swift
//  FitMate
//
//  Created by NH on 6/12/25.
//

import UIKit
import GoogleSignIn
import RxSwift
import RxRelay
import FirebaseAuth

class TestLoginViewController: UIViewController {

    let titleLabel = UILabel() // 타이틀 라벨 / 환영합니다.
    let googleLoginButton = UIButton() // 구글 로그인 버튼

    let viewModel = TestLoginViewModel() // 뷰모델
    var disposeBag = DisposeBag() // 디스포스백
    
    let googleLoginTrigger = PublishRelay<Void>() // 로그인 버튼 클릭 이벤트 전달
    let nextViewRelay = PublishRelay<Void>() // 다음 버튼 클릭 이벤트 전달

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        bindButton()
    }

    private func setupUI() {
        view.backgroundColor = .white

        titleLabel.text = "환영합니다"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

//        googleLoginButton.setImage(.googleLogo, for: .normal)
        googleLoginButton.imageView?.contentMode = .scaleAspectFit

        view.addSubview(titleLabel)
        view.addSubview(googleLoginButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }

        googleLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            
        }
        
        googleLoginButton.imageView?.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            
        }
    }

    /// 버튼 이벤트를 ViewModel로 전달
    private func bindButton() {
        googleLoginButton.rx.tap
            // UI에서 발생한 이벤트를 Relay로 보내는 상황
            .bind(to: googleLoginTrigger) // relay에 이벤트(빈 값)를 흘려보내라
            .disposed(by: disposeBag)
    }

    /// 뷰 모델 바인드
    private func bindViewModel() {
        // 명시적인 흐름과 불변성(immutable)을 유지하기 위해서 이래와 같이 선언
        let input = TestLoginViewModel.Input(
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
                    let vc = SportsSelectionViewController()
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
