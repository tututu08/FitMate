//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import Lottie
import SnapKit
import RxSwift

class LoadingViewController: BaseViewController {
    
    private let viewModel: LoadingViewModel // ViewModel 의존성 주입
    private let loadingView = LoadingView() // 뷰 객체 생성
    
    init(matchCode: String) {
        // ViewModel 의존성 주입을 통해 운동 경기 코드를 전달
        self.viewModel = LoadingViewModel(matchCode: matchCode)
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = loadingView
    }
    
    // 네비게이션 영역 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /// ViewModel 바인딩
    override func bindViewModel() {
        super.bindViewModel()
        viewModel.matchStatusEvent
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                if status == "accepted" {
                    self?.goToGameScreen()
                } else if status == "rejected" {
                    self?.presentRejectedAlert()
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 게임 화면으로 이동하는 메서드
    private func goToGameScreen() {
        // 게임화면으로 push or present
        self.navigationController?.pushViewController(RunningCoopViewController(goalText: "매칭 테스트 화면입니다!!"), animated: true)
    }
    
    /// 운동 요청 거절 시, 띄워지는 알림창 메서드
    private func presentRejectedAlert() {
        let alert = UIAlertController(title: "매칭 실패", message: "상대가 거절했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    deinit {
        print("LoadingViewController deinit")
    }
}
