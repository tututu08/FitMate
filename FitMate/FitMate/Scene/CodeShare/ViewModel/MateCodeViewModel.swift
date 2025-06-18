//
//  MateCodeViewModel.swift
//  FitMate
//
//  Created by soophie on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class MateCodeViewModel {
    /// 사용자에게 보여줄 알림 정보들
    enum AlertType {
        case codeSent /// 올바를 코드 입력 시
        case invalidCode /// 잘못된 코드 입력 시
    }
    /// 화면 이동 목적 나타내는 enum -> 메인 화면으로 이동/사용자 UID 필요
    enum Navigation {
        case goToMain(uid: String)
        case backTo
    }
    
    struct Input {
        let completeTap: Driver<Void> /// 입력 완료 버튼 눌리는 이벤트
        let enteredCode: Driver<String> /// 텍스트 필드에 입력 중인 코드
        let backTap: Driver<Void>
    }
    
    struct Output {
        let navigation: Driver<Navigation?> /// 화면 전환을 위한 상태
        let alert: Driver<AlertType?> /// 알림 표시
        let buttonActivated: Driver<Bool> /// 버튼 활성화 여부
    }
    
    func transform(input: Input) -> Output {
        /// 버튼 탭 시점에 최신 입력된 코드를 가져와서 처리
        let result = input.completeTap
            .withLatestFrom(input.enteredCode) /// 버튼을 누를 때 최신 코드 값 가져옴
            .map { entered -> (AlertType?, Navigation?) in
                let correctCode = "4444QQ"
                /// 코드가 일치?  알림 + 화면 전환
                if entered == correctCode,
                    let uid = Auth.auth().currentUser?.uid {
                    return (.codeSent, .goToMain(uid: uid))
                } else { /// 실패? 에러 알림
                    return (.invalidCode, nil)
                }
            }
            .asDriver(onErrorJustReturn: (nil, nil)) // safety 처리
        
        let goBackTo = input.backTap
            .map { Navigation.backTo as Navigation? }
            .asDriver(onErrorDriveWith: .empty())
        
        let alert = result.map { $0.0 } /// 알림 유형만 추출
        let resultNav = result.map { $0.1 }
        let navigation = Driver.merge(resultNav, goBackTo)

        
        /// 텍스트필드에 공백 외 입력이 있는지 여부로 버튼 활성 상태 결정
        let buttonActivated = input.enteredCode
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } /// 사용자가 입력한 문자열에서 앞뒤 공백과 줄바꿈 삭제
            .distinctUntilChanged()

        
        return Output(
            navigation: navigation,
            alert: alert,
            buttonActivated: buttonActivated
        )
        
    }
}
