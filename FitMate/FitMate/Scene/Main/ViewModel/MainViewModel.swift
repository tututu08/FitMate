//
//  MainViewModel.swift
//  FitMate
//
//  Created by NH on 6/16/25.
//

import RxSwift
import RxRelay

class MainViewModel {
    // 외부에서 observe할 수 있게 Observable로 노출
    let matchEvent: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init() {
        // 운동 초대 감지
        // MatchEventService의 Relay를 그대로 연결
        self.matchEvent = MatchEventService.shared.matchEventRelay.asObservable()
    }
}
