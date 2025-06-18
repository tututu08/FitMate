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
    
    let uid: String
    
    private let textLimitRelay = PublishRelay<SystemAlertType>() // 텍스트 길이 제한
    private let termsChecked = BehaviorRelay<Bool>(value: false) // 약관 체크
    private let privacyChecked = BehaviorRelay<Bool>(value: false) // 개인정보 체크
    
    private let isValidNicknameRelay = BehaviorRelay<Bool>(value: false)
    private let currentNicknameRelay = BehaviorRelay<String>(value: "")
    
    var disposeBag = DisposeBag()
    
    init(uid: String) {
        self.uid = uid
    }
    
    struct Input {
        let enteredCode: Driver<String> // 닉네임 입력
        //let textFieldLimit: Driver<Void> // 텍스트 제한 트리거
        let textFieldLimit: Driver<SystemAlertType> // 텍스트 제한 트리거
        let termsTap: Observable<Void> // 약관
        let privacyTap: Observable<Void> // 개인정보 체크
        
        let nicknameText: Observable<String> // 닉네임 입력 텍스트
        let registerTap: Observable<Void> // 버튼 탭 이벤트 추가
    }
    
    struct Output {
        let buttonActivated: Driver<Bool> // 버튼 활성화
        let showAlert: Driver<SystemAlertType> // 알림 띄우기
        
        let termsChecked: Driver<Bool> // 약관
        let privacyChecked: Driver<Bool> // 개인정보 체크
        let nicknameSaved: Driver<Void> // 저장 완료 이벤트
    }
    
    func transform(input: Input) -> Output {
        let nicknameSaved = PublishRelay<Void>()
        
        let buttonActivated = input.enteredCode
            // 개행이랑 공백일 경우 버튼 활성화 제한
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } /// 사용자가 입력한 문자열에서 앞뒤 공백과 줄바꿈
            .distinctUntilChanged() // 이전 값과 같으면 무시
            
        input.textFieldLimit
            //.map { SystemAlertType.overLimit } // 문자열 길이 초과 시 알림 타입 생성
            .drive(onNext: { [weak self] alert in
                    self?.textLimitRelay.accept(alert)
                })
            .disposed(by: disposeBag)
        
        // 닉네임 중복이면 알림 띄움
        input.nicknameText
            // 사용자가 타이핑을 멈춘 뒤 0.3초 동안 입력이 없을 때만 다음 로직을 실행
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            // 동일한 닉네임이 연속해서 들어오면 무시
            .distinctUntilChanged()
            // 닉네임이 바뀔 때마다 Firestore에 중복 체크 요청
            .flatMapLatest { nickname in
                //Firestore에 해당 닉네임이 이미 존재하는지 확인하는 메서드를 호출
                FirestoreService.shared.nicknameCheck(nickname: nickname)
                    .map { (nickname, $0) } // 튜플로 전달
                    .asObservable()
                    // Firestore 에러가 발생해도 스트림을 끊지 않고 false를 대신 반환
                    .catchAndReturn((nickname, false))
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] nickname, isDuplicate in
                print("[중복검사] 닉네임: \(nickname), 중복여부: \(isDuplicate)")
                guard let self = self else { return }
                if isDuplicate {
                    self.textLimitRelay.accept(.duplicateNickname)
                    self.isValidNicknameRelay.accept(false)
                } else {
                    self.isValidNicknameRelay.accept(true)
                    self.currentNicknameRelay.accept(nickname)
                }
            })
            .disposed(by: disposeBag)
        
        input.registerTap
            .withLatestFrom(Observable.combineLatest(isValidNicknameRelay, currentNicknameRelay))
            .filter { isValid, _ in isValid } // 유효할 때만 저장
            .flatMapLatest { _, nickname in
                FirestoreService.shared.updateDocument(collectionName: "users", documentName: self.uid, fields: ["nickname": nickname])
                    .asObservable()
                    .catchAndReturn(())
            }
            .bind(to: nicknameSaved)
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
            privacyChecked: privacyChecked.asDriver(),
            nicknameSaved: nicknameSaved.asDriver(onErrorDriveWith: .empty())
        )
    }
}
