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
        
        // 선택된 언어가 있는 경우에만 선택 완료 버튼 활성화
        output.buttonActivated
            .drive(onNext: { [weak self] activated in
                guard let self = self else { return }
                let button = self.languageView.selectButton
                
                button.isEnabled = activated // 버튼 활성화 여부 설정
                button.backgroundColor = activated ? UIColor.primary500 : UIColor.background50
                button.setTitleColor(activated ? .white : .background500, for: .normal)
            })
            .disposed(by: disposeBag)
        
        // 선택된 언어에 따라 버튼 선택 상태 갱신
        output.selectedLanguage
            .drive(onNext: { [weak self] selected in
                guard let self else { return }
                self.languageView.updateSelectedLanguage(selected) // 해당 언어만 selected 상태로 갱신
            })
            .disposed(by: disposeBag)
    }
    
    /// 언어 버튼의 탭 이벤트를 처리하여 Relay에 바인딩
    private func bindButtonTaps() {
        // 언어 버튼 리스트를 순회하며 각각의 버튼에 이벤트 연결
        for (index, button) in languageView.languagesButtons.enumerated() {
            let option = LanguagesOption.allCases[index]
            // 탭 이벤트 발생하면 해당 언어 옵션을 Relay에 전달
            button.rx.tap
                .map { option }
                .bind(to: languageTapRelay)
                .disposed(by: disposeBag)
        }
    }
}
