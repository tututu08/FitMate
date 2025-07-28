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
    
    private let languageRelay = BehaviorRelay<LanguagesOption?>(value: nil) // 현재 선택된 언어 저장
    private var disposeBag = DisposeBag()
    
    struct Input {
        let languageSelected: Driver<LanguagesOption> // 유저가 언어 버튼 선택할때 발생하는 이벤트
    }
    
    struct Output {
        let buttonActivated: Driver<Bool> // 버튼 활성화
        let selectedLanguage: Driver<LanguagesOption?> // 현재 선택된 언어를 UI에 갱신
    }
    
    func transform(input: Input) -> Output {
        /// 사용자가 선택한 언어
        input.languageSelected
            .drive(languageRelay)
            .disposed(by: disposeBag)
        
        // languageRelay 값이 nil이 아니면 버튼 활성화
        let buttonActivated = languageRelay
            .map { $0 != nil } // 언어가 선택되었는가
            .asDriver(onErrorJustReturn: false)
        
        // 현재 선택된 언어를 그대로 외부에 전달
        let selectedLanguage = languageRelay
            .asDriver(onErrorJustReturn: nil)
        
        return Output(
            buttonActivated: buttonActivated,
            selectedLanguage: selectedLanguage
        )
    }
}
