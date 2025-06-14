//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import Lottie
import SnapKit

class LoadingViewController: BaseViewController {
    
   private let loadingView = LoadingView()
    
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
