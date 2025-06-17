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
    
    func setCode(_ code: String) {
        copyRelay.accept(code)
    }
    
    func transform(input: Input) -> Output {
        FirestoreService.shared
                .fetchDocument(collectionName: "codes", documentName: "mateCode")
                .map { $0["value"] as? String ?? "" }
                .subscribe(onSuccess: { [weak self] code in
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
