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
    
    let viewModel: LoadingViewModel
    private let loadingView = LoadingView()
    
    init(matchCode: String) {
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
    
}
