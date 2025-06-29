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
    let termsWebView = PublishRelay<Void>()
    let privacyWebView = PublishRelay<Void>()
    private let isValidNicknameRelay = BehaviorRelay<Bool>(value: false)
    private let currentNicknameRelay = BehaviorRelay<String>(value: "") // 닉네임 저장 목적에 맞는 값
    private let validMessageRelay = BehaviorRelay<String>(value: "")
    let textRelay = BehaviorRelay<String>(value: "") // 검증 대상이 되는 새로운 입력 값
    var disposeBag = DisposeBag()
    
    init(uid: String) {
        self.uid = uid
    }
    
    struct Input {
        let enteredCode: Driver<String> // 닉네임 입력
        //let textFieldLimit: Driver<Void> // 텍스트 제한 트리거
        let textFieldLimit: Driver<SystemAlertType> // 텍스트 제한 트리거
        let termsToggleTap: Observable<Void> // 서비스 약관 / 체크박스
        let privacyToggleTap: Observable<Void> // 개인정보약관 / 체크박스
        let termsLabelTap: Observable<Void> // 서비스 약관 / 타이틀
        let privacyLabelTap: Observable<Void> // 개인정보약관 / 타이틀
        //        let nicknameText: Observable<String> // 닉네임 입력 텍스트
        let registerTap: Observable<Void> // 버튼 탭 이벤트 추가
    }
    
    struct Output {
        let buttonActivated: Driver<Bool> // 버튼 활성화
        let showAlert: Driver<SystemAlertType> // 알림 띄우기
        
        let termsChecked: Driver<Bool> // 약관
        let privacyChecked: Driver<Bool> // 개인정보 체크
        let termsWebView: Driver<Void>
        let privacyWebView: Driver<Void>
        let nicknameSaved: Driver<Void> // 저장 완료 이벤트
        let validMessage: Driver<String>
    }
    
    private func validNickname(_ nickname: String) -> Bool {
        let pattern = "^[A-Za-z가-힣0-9]{1,8}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        // 문자열 시작 위치-location: 0 부터
        // 전체 문자열의 길이-length: nickname.utf16.count 만큼 검사
        let range = NSRange(location: 0, length: nickname.utf16.count)
        return regex.firstMatch(in: nickname, options: [], range: range) != nil
    }
    
    func transform(input: Input) -> Output {
        let nicknameSaved = PublishRelay<Void>()
        
        let buttonActivated = Observable
            .combineLatest(
                input.enteredCode.asObservable()
                // // 입력된 닉네임이 공백이 아닌지 판단
                    .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                // 닉네임 중복 검사를 통과했는지
                isValidNicknameRelay.asObservable(),
                // 약관 체크박스가 체크되었는지
                termsChecked.asObservable(),
                // 개인정보 처리방침 체크박스가 체크되었는지
                privacyChecked.asObservable()
            )
        // 위 네 조건이 모두 true일 때만 버튼을 활성화/
            .map { inputNotEmpty, isValidNickname, termsOK, privacyOK in
                inputNotEmpty && isValidNickname && termsOK && privacyOK
            }
        // 이전 값과 같으면 무시하고 변경된 경우에만 전달
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        input.textFieldLimit
        //.map { SystemAlertType.overLimit } // 문자열 길이 초과 시 알림 타입 생성
            .drive(onNext: { [weak self] alert in
                self?.textLimitRelay.accept(alert)
            })
            .disposed(by: disposeBag)
        
        /// 기존 input.ninameText에서 textRelay로 별도 보관하는 방식으로 변경
        /// ViewModel 내부에서 입력 값을 직접 보관하고 가공 가능
        /// textRelay는 뷰컨이나 텍스트필드에서 바인딩된 실시간 입력 값을 저장
        /// 실시간 닉네임 유효성 검사에 사용됨
        /// 그리고 검증을 통과한 닉네임이 currentNicknameRelay에 저장
        textRelay
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { text -> Observable<(Bool, String)> in
                let blank = text.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if blank.isEmpty {
                    return .just((false, "닉네임을 입력해주세요"))
                } else if text.contains(where: { $0.isWhitespace }) {
                    return .just((false, "닉네임에 공백은 사용할 수 없어요"))
                }
                if !self.validNickname(text) {
                    return .just((false, "닉네임은 영문, 숫자, 한글만 사용할 수 있어요"))
                }
                if text.count < 2 {
                    return .just((false, "닉네임은 2글자 이상이어야 해요."))
                } else if text.count > 8 {
                    return .just((false, "8글자 이하로 입력해주세요."))
                } else {
                    return FirestoreService.shared.nicknameCheck(nickname: text)
                        .map { isExist in
                            if isExist {
                                return (false, "이미 존재하는 닉네임이에요.")
                            } else {
                                return (true, "사용 가능한 닉네임입니다.")
                            }
                        }
                        .asObservable()
                        .catchAndReturn((false, "닉네임 중복 검사 실패"))
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isValid, message in
                self?.isValidNicknameRelay.accept(isValid)
                self?.validMessageRelay.accept(message)
                if isValid {
                    self?.currentNicknameRelay.accept(self?.textRelay.value ?? "")
                }
            })
            .disposed(by: disposeBag)
        
        input.registerTap
        // 버튼이 눌렸을 때 최신 상태의 4가지 => 닉네임 유효성, 닉네임 값, 약관 체크, 개인정보 체크
            .withLatestFrom(
                Observable.combineLatest(
                    isValidNicknameRelay, // 닉네임 중복 검사 통과 여부
                    currentNicknameRelay, // 현재 입력된 닉네임
                    termsChecked, // 약관 체크 여부
                    privacyChecked // 개인정보 체크 여부
                )
            )
        // 세 가지 조건이 모두 true인 경우에만 저장
            .filter { isValidNickname, _, termsOK, privacyOK in
                isValidNickname && termsOK && privacyOK
            }
        // 조건이 통과되면 닉네임만 추출해서 Firestore에 저장 요청
            .flatMapLatest { _, nickname, _, _ in
                FirestoreService.shared.updateDocument(
                    collectionName: "users", // users 컬렉션
                    documentName: self.uid, // 현재 로그인한 유저 문서
                    fields: ["nickname": nickname] // 업데이트할 필드
                )
                .asObservable()
                .catchAndReturn(())
            }
            .bind(to: nicknameSaved)
            .disposed(by: disposeBag)
        
        input.termsToggleTap
            .bind { [weak self] in
                guard let self = self else { return }
                self.termsChecked.accept(!self.termsChecked.value)
            }
            .disposed(by: disposeBag)
        
        input.privacyToggleTap
            .bind { [weak self] in
                guard let self = self else { return }
                self.privacyChecked.accept(!self.privacyChecked.value)
            }
            .disposed(by: disposeBag)
        
        input.termsLabelTap
            .bind(to: termsWebView)
            .disposed(by: disposeBag)
        
        input.privacyLabelTap
            .bind(to: privacyWebView)
            .disposed(by: disposeBag)
        
        return Output(
            buttonActivated: buttonActivated,
            showAlert: textLimitRelay.asDriver(onErrorDriveWith: .empty()),
            termsChecked: termsChecked.asDriver(),
            privacyChecked: privacyChecked.asDriver(),
            termsWebView: termsWebView.asDriver(onErrorDriveWith: .empty()),
            privacyWebView: privacyWebView.asDriver(onErrorDriveWith: .empty()),
            nicknameSaved: nicknameSaved.asDriver(onErrorDriveWith: .empty()),
            validMessage: validMessageRelay.asDriver()
        )
    }
}
