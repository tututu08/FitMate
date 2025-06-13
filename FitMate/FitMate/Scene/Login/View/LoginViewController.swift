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
    
    let logInView = LoginView()
    
    override func loadView() {
        super.loadView()
        self.view = logInView
    }
    
//    override func bindViewModel() {
//        <#code#>
//    }
}
