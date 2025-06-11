//
//  NIcknameViewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import RxSwift
import RxCocoa

class NicknameViewController: BaseViewController {
    
    private let nicknameView = NicknameView()
    
    override func loadView() {
        self.view = nicknameView
    }
    
    override func bindViewModel() {
        nicknameView.registerButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                let codeShareView = CodeShareVIewController()
                self?.navigationController?.pushViewController(
                    codeShareView, animated: true)
            })
            .disposed(by: disposeBag)
    }


}
