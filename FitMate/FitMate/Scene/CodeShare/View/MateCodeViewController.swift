//
//  MateCodeVIewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//
import UIKit
import RxSwift
import RxCocoa

class MateCodeViewController: BaseViewController {
    
    private let mateCodeView = MateCodeView()
    
    override func loadView() {
        self.view = mateCodeView
        
    }
    // 시스템 네비게이션바 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func bindViewModel() {
        mateCodeView.backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
