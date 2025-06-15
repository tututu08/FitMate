//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: BaseViewController {
    
    private let mainView = MainView()
    
    override func loadView() {
        self.view = mainView
        mainView.changeAvatarLayout(hasMate: true)
        navigationItem.backButtonTitle = ""
    }
    
//    // 네비게이션 영역 숨김
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
    
    override func bindViewModel() {
        mainView.exerciseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.pushViewController(SportsSelectionViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
}
