//
//  LoadingViewModel.swift
//  FitMate
//
//  Created by NH on 6/16/25.
//

import RxSwift
import RxRelay

class LoadingViewModel {
    // 화면으로 match 상태 이벤트 전달 (started, canceled 등)
    let matchStatusEvent = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    private let matchCode: String
    
    init(matchCode: String, myUid: String) {
        self.matchCode = matchCode
        print("matchCode : \(matchCode)")
        
        // 내 상태와 준비 완료 표시
        MatchEventService.shared.updateMyStatus(
            matchCode: matchCode,
            myUid: myUid,
            status: "accepted"
        )
        MatchEventService.shared.markReady(matchCode: matchCode, myUid: myUid)

        // matchStatusRelay 구독해서 상태 바뀔 때마다 matchStatusEvent로 전달
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
        print("로딩 뷰모델 디이닛")
    }
}
