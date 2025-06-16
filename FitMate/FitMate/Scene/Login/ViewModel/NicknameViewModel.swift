//
//  NicknameViewModel.swift
//  FitMate
//
//  Created by NH on 6/17/25.
//

import Foundation
import RxSwift
import RxCocoa

enum NicknameNavigation {
    case none // 아무 상태도 아님(초기 상태)
    case goNext(uid: String) // 다음 화면으로 이동해야 할 때
    case error(String) // 에러(메시지와 함께)
}

final class NicknameViewModel {
    struct Input {
        let nicknameText: Observable<String?> // 닉네임 입력 텍스트
        let nextButtonTap: Observable<Void>   // 다음 버튼 클릭 이벤트
        let uid: String                       // 사용자 고유 id (필수)
    }
    
    struct Output {
        let validationMessage: Driver<String>    // 유효성 메시지 출력용
        let isValidNickname: Driver<Bool>        // 닉네임 사용 가능 여부
        let step: Driver<NicknameNavigation>           // 다음 화면 이동 등 상태 신호
    }
    
    // 내부적으로 유효성 메시지/상태를 관리하는 Relay
    private let validationMessageRelay = BehaviorRelay<String>(value: "")
    private let isValidNicknameRelay = BehaviorRelay<Bool>(value: false)
    private let stepRelay = PublishRelay<NicknameNavigation>()
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 닉네임 텍스트 입력 스트림 (nil 제거, 중복 입력 방지, 최신 값만 유지)
        let nicknameText = input.nicknameText
            .compactMap { $0 }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
        
        // 닉네임 입력시마다 유효성 검사 (2~6글자 & Firestore 중복 검사)
        nicknameText
            .flatMapLatest { text -> Observable<(Bool, String)> in
                if text.count < 2 {
                    return .just((false, "닉네임은 2글자 이상이여야 됩니다."))
                } else if text.count > 6 {
                    return .just((false, "닉네임이 6글자를 넘어갔습니다."))
                } else {
                    // Firestore에서 중복 닉네임 체크
                    return FirestoreService.shared.nicknameCheck(nickname: text)
                        .map { isExist in
                            if isExist {
                                return (false, "이미 존재하는 닉네임입니다.")
                            } else {
                                return (true, "사용 가능한 닉네임입니다.")
                            }
                        }
                        .asObservable()
                }
            }
        // 결과를 BehaviorRelay에 반영 (메시지/유효성 여부 업데이트)
            .subscribe(onNext: { [weak self] isValid, message in
                self?.isValidNicknameRelay.accept(isValid)
                self?.validationMessageRelay.accept(message)
            })
            .disposed(by: disposeBag)
        
        // "다음" 버튼 탭 시 → 유효성 통과한 닉네임만 처리
        input.nextButtonTap
        // 최신 유효성 및 닉네임 값을 함께 가져옴
            .withLatestFrom(Observable.combineLatest(isValidNicknameRelay, nicknameText))
        // 유효성 OK인 경우만 통과
            .filter { isValid, _ in isValid }
            .map { _, nickname in nickname }
        // 닉네임 저장 및 "이동 신호" 방출
            .subscribe(onNext: { [weak self] nickname in
                guard let self else { return }
                guard !input.uid.isEmpty else {
                    // uid가 비어 있으면 에러 신호 방출
                    self.stepRelay.accept(.error("uid가 비어있습니다"))
                    return
                }
                               
                FirestoreService.shared.updateDocument(collectionName: "users", documentName: input.uid, fields: ["nickname": nickname])
                    .subscribe(
                        onSuccess: {
                            print("닉네임 등록 성공")
                        },
                        onFailure: { error in
                            print("실패 \(error.localizedDescription)")
                        }
                    ).disposed(by: self.disposeBag)
                
                // 저장 완료 후 다음 화면 이동 신호
                self.stepRelay.accept(.goNext(uid: input.uid))
            }).disposed(by: disposeBag)
        
        // Output: 뷰에서 구독할 수 있도록 내보냄
        return Output(
            validationMessage: validationMessageRelay.asDriver(), // 메시지 라벨용
            isValidNickname: isValidNicknameRelay.asDriver(),     // 필요시 버튼 활성화 등
            step: stepRelay.asDriver(onErrorJustReturn: .error("알 수 없는 오류")) // 화면 이동 등 상태 신호
        )
    }
}
