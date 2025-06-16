//
//  NicknameViewModel.swift
//  FitMate
//
//  Created by soophie on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class NicknameViewModel {
    
    private let textLimitRelay = PublishRelay<SystemAlertType>()
    private let termsChecked = BehaviorRelay<Bool>(value: false)
    private let privacyChecked = BehaviorRelay<Bool>(value: false)
    var disposeBag = DisposeBag()
    
    struct Input {
        let enteredCode: Driver<String>
        let textFieldLimit: Driver<Void>
        let termsTap: Observable<Void>
        let privacyTap: Observable<Void>
    }
    
    struct Output {
        let buttonActivated: Driver<Bool>
        let showAlert: Driver<SystemAlertType>
        
        let termsChecked: Driver<Bool>
        let privacyChecked: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let buttonActivated = input.enteredCode
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } /// 용자가 입력한 문자열에서 앞뒤 공백과 줄바꿈
            .distinctUntilChanged()
        
        input.textFieldLimit
            .map { SystemAlertType.overLimit } // 문자열 길이 초과 시 알림 타입 생성
            .drive(onNext: { [weak self] alert in
                    self?.textLimitRelay.accept(alert)
                })
            .disposed(by: disposeBag)
        
        input.termsTap
            .bind { [weak self] in
                guard let self = self else { return }
                self.termsChecked.accept(!self.termsChecked.value)
            }
            .disposed(by: disposeBag)
        
        input.privacyTap
            .bind { [weak self] in
                guard let self = self else { return }
                self.privacyChecked.accept(!self.privacyChecked.value)
            }
            .disposed(by: disposeBag)
        
        return Output(
            buttonActivated: buttonActivated,
            showAlert: textLimitRelay.asDriver(onErrorDriveWith: .empty()),
            termsChecked: termsChecked.asDriver(),
            privacyChecked: privacyChecked.asDriver()
        )
    }
}
