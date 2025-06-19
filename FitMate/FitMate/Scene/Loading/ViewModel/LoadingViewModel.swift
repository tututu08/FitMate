//
//  LoadingViewModel.swift
//  FitMate
//
//  Created by NH on 6/16/25.
//

import RxSwift
import RxRelay

class LoadingViewModel {
    // 화면으로 상태 이벤트 전달
    let matchStatusEvent = PublishRelay<String>() // accepted, rejected 등
    
    private let disposeBag = DisposeBag()
    private let matchCode: String
    
    init(matchCode: String) {
        self.matchCode = matchCode
        print("matchCode : \(matchCode)")
        bindMatchStatus()
    }
    
    private func bindMatchStatus() {
        MatchEventService.shared.listenMatchStatus(matchCode: matchCode)
        
        MatchEventService.shared.matchStatusRelay
            .map { $0[self.matchCode] ?? "" }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .do(onNext: { status in
                print("ViewModel: matchStatusRelay에서 \(status) 받음")
            })
            .bind(to: matchStatusEvent)
            .disposed(by: disposeBag)
    }
    
    deinit {
        MatchEventService.shared.stopListening()
        print("로딩 뷰모델 디인잇")
    }
}
