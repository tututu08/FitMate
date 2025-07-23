//
//  LanguagesViewController.swift
//  FitMate
//
//  Created by sophie on 7/23/25.
//

import UIKit
import RxSwift
import RxCocoa

class LanguagesViewController: BaseViewController {
    
    private let languageView = LanguagesView()
    private let languagesViewModel = LanguagesViewModel()
    private let languageTapRelay = PublishRelay<LanguagesOption>()
    
    override func loadView() {
        self.view = languageView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        bindButtonTaps()
    }
    
    override func bindViewModel() {
        
        let input = LanguagesViewModel.Input(languageSelected: languageTapRelay.asDriver(onErrorDriveWith: .empty()))
        
        let output = languagesViewModel.transform(input: input)
        
        output.buttonActivated
            .drive(onNext: { [weak self] activated in
                guard let self = self else { return }
                let button = self.languageView.selectButton
                
                button.isEnabled = activated // 버튼 활성화 여부 설정
                button.backgroundColor = activated ? UIColor.primary500 : UIColor.background50
                button.setTitleColor(activated ? .white : .background500, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.selectedLanguage
            .drive(onNext: { [weak self] selected in
                guard let self else { return }
                self.languageView.updateSelectedLanguage(selected)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindButtonTaps() {
        for (index, button) in languageView.languagesButtons.enumerated() {
            let option = LanguagesOption.allCases[index]
            button.rx.tap
                .map { option }
                .bind(to: languageTapRelay)
                .disposed(by: disposeBag)
        }
    }
}
