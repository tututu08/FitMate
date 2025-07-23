//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: BaseViewController {
    
    private let viewModel: MainViewModel
    let mainView = MainView()
    private let uid: String
    private let mateUid: String?
    
    
    init(uid: String, mateUid: String?) {
        self.uid = uid
        self.mateUid = mateUid
        self.viewModel = MainViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        self.view = mainView
        navigationItem.backButtonTitle = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindAvatarRelays()
        
        if let avatarType = AvatarManager.shared.selectedAvatarRelay.value {
            mainView.myAvatarImage.image = UIImage(named: avatarType.imageName)
        }
        
        AvatarManager.shared.fetchInitialAvatar(uid: uid)
        
        if let mateUid = mateUid {
            AvatarManager.shared.fetchMateAvatar(uid: mateUid)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        fetchMateStatusAndUpdateUI()
        fetchMyCoin(uid: uid)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func bindAvatarRelays() {
        AvatarManager.shared.selectedAvatarRelay
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] avatarType in
                guard let self,
                      let image = UIImage(named: avatarType.imageName),
                      let cgImage = image.cgImage else { return }
                let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                self.mainView.myAvatarImage.image = fixed
            }
            .disposed(by: disposeBag)
        
        AvatarManager.shared.mateAvatarRelay
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] avatarType in
                guard let self,
                      let image = UIImage(named: avatarType.imageName),
                      let cgImage = image.cgImage else { return }
                let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                self.mainView.mateAvatarImage.image = fixed
            }
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = MainViewModel.Input(
            exerciseTap: mainView.exerciseButton.rx.tap.asObservable(),
            mateAvatarTap: mainView.mateAvatarImage.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.hasNoMate
            .drive(onNext: { [weak self] in
                guard let self else { return }
                let vc = CodeShareViewController(uid: self.uid, hasMate: false)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                nav.modalTransitionStyle = .coverVertical
                self.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.moveToExercise
            .drive(onNext: { [weak self] in
                guard let self else { return }
                let vc = SportsSelectionViewController(uid: self.uid)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.moveToMatePage
            .drive(onNext: { [weak self] mateUid in
                guard let self else { return }
                let vc = MatepageViewController(mateUid: mateUid)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.showMateDisconnected
            .drive(onNext: { [weak self] in
                self?.presentMateAlert(description: "기록은 보관되어 있으니 언제든 확인할 수 있습니다.\n새로운 메이트를 추가해 운동을 이어가보세요.")
            })
            .disposed(by: disposeBag)
        
        output.showMateWithdrawn
            .drive(onNext: { [weak self] in
                self?.presentMateAlert(description: "메이트가 회원탈퇴 했어요")
            })
            .disposed(by: disposeBag)
    }
    
    
    private func fetchMateStatusAndUpdateUI() {
        mainView.alpha = 0
        
        FirestoreService.shared.fetchDocument(collectionName: "users", documentName: uid)
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                let hasMate = data["hasMate"] as? Bool ?? false
                let myNickname = data["nickname"] as? String ?? "나"
                
                if hasMate,
                   let mate = data["mate"] as? [String: Any],
                   let mateNickname = mate["nickname"] as? String {
                    if let mateUid = mate["uid"] as? String {
                        self.updateMateAvatarImage(mateUid: mateUid)
                    }
                    self.mainView.changeAvatarLayout(hasMate: true, myNickname: myNickname, mateNickname: mateNickname)
                    if let startDateString = mate["startDate"] as? String,
                       let dDay = calculateDDay(from: startDateString) {
                        self.mainView.dDaysLabel.text = "\(dDay)일째"
                    }
                    UIView.animate(withDuration: 0.2) {
                        self.mainView.alpha = 1
                    }
                } else {
                    self.mainView.dDaysLabel.text = "0일째..."
                    self.mainView.changeAvatarLayout(hasMate: false, myNickname: myNickname, mateNickname: "")
                    UIView.animate(withDuration: 0.2) {
                        self.mainView.alpha = 1
                    }
                }
            }, onFailure: { error in
                print("메이트 상태 조회 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchMyCoin(uid: String) {
        FirestoreService.shared.fetchDocument(collectionName: "users", documentName: uid)
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                if let coin = data["coin"] as? Int {
                    self.mainView.coinLabel.text = "\(coin)"
                }
            }, onFailure: { error in
                print("코인 조회 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    private func presentMateAlert(description: String) {
        let popup = PartnerLeftAlertView()
        popup.configure(description: description)
        popup.alpha = 0
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(popup)
            popup.snp.makeConstraints { $0.edges.equalToSuperview() }
            UIView.animate(withDuration: 0.25) { popup.alpha = 1 }
            
            popup.confirmButton.rx.tap
                .bind { [weak self, weak popup] in
                    guard let self, let popup else { return }
                    UIView.animate(withDuration: 0.2, animations: {
                        popup.alpha = 0
                    }) { _ in
                        popup.removeFromSuperview()
                        self.cleanupMateAndRefresh()
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func cleanupMateAndRefresh() {
        FirestoreService.shared.deleteMate(myUid: uid)
            .subscribe(onSuccess: { [weak self] in
                self?.fetchMateStatusAndUpdateUI()
            }, onFailure: { error in
                print("삭제 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    private func updateMateAvatarImage(mateUid: String) {
        AvatarManager.shared.fetchMateAvatar(uid: mateUid)
    }
    
    private func calculateDDay(from startDateString: String) -> Int? {
        let formatter = FirestoreService.dateFormatter
        guard let startDate = formatter.date(from: startDateString) else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: startDate)
        let components = Calendar.current.dateComponents([.day], from: start, to: today)
        return (components.day ?? 0) + 1
    }
}


extension Reactive where Base: UIImageView {
    var tap: Observable<Void> {
        let tapGesture = UITapGestureRecognizer()
        base.addGestureRecognizer(tapGesture)
        base.isUserInteractionEnabled = true
        return tapGesture.rx.event.map { _ in () }
    }
}
