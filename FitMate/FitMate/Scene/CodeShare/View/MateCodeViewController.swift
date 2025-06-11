//
//  MateCodeVIewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MateCodeViewController: BaseViewController {
    
    private let mateCodeView = MateCodeView()
    
    override func loadView() {
        self.view = mateCodeView
    }
    
    override func bindViewModel() {
        mateCodeView.backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
