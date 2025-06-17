//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class CodeShareViewModel {
    
    private let copyRelay = BehaviorRelay<String>(value: "")
    private let copyTapRelay = PublishRelay<Void>()
    private let alertRelay = PublishRelay<SystemAlertType>()
    
    let uid: String
    
    init(uid: String) {
        self.uid = uid
    }
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let copyTab: Observable<Void>
    }
    
    struct Output {
        let copiedText: Observable<String>
        let showAlert: Driver<SystemAlertType>
    }
    /// 외부에서 전달받은 코드를 내부 relay로 전달
    func setCode(_ code: String) {
        copyRelay.accept(code)
    }
    
    func transform(input: Input) -> Output {
        FirestoreService.shared
                .fetchDocument(collectionName: "codes", documentName: "mateCode")
                // 가져온 Document에서 "value" 필드를 꺼내 String으로 변환
                .map { $0["value"] as? String ?? "" }
                .subscribe(onSuccess: { [weak self] code in
                    // 성공적으로 값을 받아오면 setCode 메서드를 통해 relay에 저장
                        self?.setCode(code)
                    }, onFailure: { error in
                        print("Firestore fetch error: \(error.localizedDescription)")
                .disposed(by: disposeBag)
        
        // 복사 버튼
        input.copyTab
            .withLatestFrom(copyRelay)
            .do(onNext: { code in
                UIPasteboard.general.string = code
            })
            .map { _ in
                SystemAlertType.copied
            }
            .bind(to: alertRelay)
            .disposed(by: disposeBag)
        
        return Output(
            copiedText: copyRelay.asObservable(),
            showAlert: alertRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
