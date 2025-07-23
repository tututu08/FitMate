//
//  LanguagesViewModel.swift
//  FitMate
//
//  Created by sophie on 7/23/25.
//

import Foundation
import RxSwift
import RxCocoa

class LanguagesViewModel {
    
    private let languageRelay = BehaviorRelay<LanguagesOption?>(value: nil)
    private var disposeBag = DisposeBag()
    
    struct Input {
        let languageSelected: Driver<LanguagesOption>
    }
    
    struct Output {
        let buttonActivated: Driver<Bool> // 버튼 활성화
        let selectedLanguage: Driver<LanguagesOption?>
    }
    
    func transform(input: Input) -> Output {
        input.languageSelected
            .drive(languageRelay)
            .disposed(by: disposeBag)
        let buttonActivated = languageRelay
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
        
        let selectedLanguage = languageRelay
            .asDriver(onErrorJustReturn: nil)
        
        return Output(
            buttonActivated: buttonActivated,
            selectedLanguage: selectedLanguage
        )
    }
}
