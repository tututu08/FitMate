//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class ShopViewController: BaseViewController, UICollectionViewDelegateFlowLayout {
    
    private let rootView = ShopView()
    private let viewModel = ShopViewModel()
    private let selectedCategorySubject = PublishSubject<RankCategory>()
    private let filteredTypes: [RankCategory] = RankCategory.allCases
    private let mateUid: String?
    // 중복 바인딩 방지를 위한 플래그
    private var didBindAvatar = false
    private var didSelectInitialKaepy = false
    
    private let uid: String
    private var myCoin: Int = 0
    init(uid: String, mateUid: String?) {
        self.uid = uid
        self.mateUid = mateUid
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 자신의 코인 불러오기
        fetchMyCoin(uid: self.uid)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //        viewModel.fetchAvatars(uid: uid)
        // 먼저 대표 아바타 타입 불러오기
        viewModel.fetchSelectedAvatarType(uid: uid)
        
        // 그리고 전체 아바타 불러오기
        viewModel.fetchAvatars(uid: uid)
        
        rootView.categoryCollectionView.delegate = nil
        bindCategoryViewModel()
        
        let initialIndexPath = IndexPath(item: 0, section: 0)
        rootView.categoryCollectionView.selectItem(at: initialIndexPath, animated: false, scrollPosition: [])
        selectedCategorySubject.onNext(filteredTypes[0])
    }
    
    // 반복적인 delegate proxy 충돌
    // 방지를 위해 카테고리와 아바타 컬렉션 Rx 바인딩 시점 조절
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// viewDidAppear는 탭 전환할 때마다 호출되는데
        /// bindAvatarViewModel() 안에 rx.item이 있어서 delegate proxy 자꾸 건드림
        /// didBindAvatar를 통해 한 번만 바인딩되도록 보장
        if !didBindAvatar {
            bindAvatarViewModel()
            didBindAvatar = true
        }
    }
    
    // 카테고리 컬렉션뷰 바인딩
    private func bindCategoryViewModel() {
        rootView.categoryCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        Observable.just(filteredTypes)
            .bind(to: rootView.categoryCollectionView.rx.items(
                cellIdentifier: ShopCategoryCell.id,
                cellType: ShopCategoryCell.self)
            ) { [weak self] index, type, cell in
                let currentSelected = self?.viewModel.selectedCategoryRelay.value
                let isSelected = (type == currentSelected)
                cell.configure(with: type, isSelected: isSelected)
            }
            .disposed(by: disposeBag)
        
        rootView.categoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.selectedCategorySubject.onNext(self.filteredTypes[indexPath.item])
                self.rootView.categoryCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAvatarViewModel() {
        let input = ShopViewModel.Input(
            selectedCategory: selectedCategorySubject.asObservable(),
            selectedAvatar: rootView.avatarCollection.rx.modelSelected(AvatarModel.self).asObservable()
        )
        
//        let selectedAvatarInfo = viewModel.selectedAvatarRelay
//            .compactMap { $0 }
        
        let output = viewModel.transform(input: input)
        
        // 아바타 목록 → 컬렉션뷰 바인딩
        output.selectedAvatar
            .drive(rootView.avatarCollection.rx.items(
                cellIdentifier: AvatarCell.id,
                cellType: AvatarCell.self
            )) { [weak self] index, model, cell in
                guard let self else { return }
                cell.configure(with: model)
                
                if !self.didSelectInitialKaepy,
                   self.viewModel.selectedAvatarRelay.value == nil,
                   self.viewModel.selectedPreviewAvatarRelay.value == nil,
                   model.type == .kaepy {

                    let indexPath = IndexPath(item: index, section: 0)
                    self.rootView.avatarCollection.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    self.viewModel.selectedPreviewAvatarRelay.accept(model)
                    self.didSelectInitialKaepy = true
                }
            }
            .disposed(by: disposeBag)
        
        // 셀 선택 → 미리보기용 previewRelay에만 반영
        rootView.avatarCollection.rx.modelSelected(AvatarModel.self)
            .bind(to: viewModel.selectedPreviewAvatarRelay)
            .disposed(by: disposeBag)
        
        // 구매 팝업 처리
        rootView.avatarCollection.rx.itemSelected
            .asObservable()
            .withLatestFrom(viewModel.currentFilteredAvatars) { indexPath, avatars in
                avatars[indexPath.item]
            }
            .filter { !$0.isUnlocked }
            .subscribe(onNext: { [weak self] model in
                guard let self else { return }
                guard let imageName = model.imageName else { return }

                let popup = AvatarPopUpViewController(
                    alertType: .avatarPurchase(
                        name: model.avatarName,
                        cost: model.conCost ?? 0
                    )
                )
                
                popup.configure(avatarImageName: imageName, coinCost: model.conCost ?? 0)
                
                popup.onConfirm = {
                    // print("나의 잔고 : \(self.myCoin)")
                  
                    guard let conCost = model.conCost else {
                        print("아바타 가격 정보가 없습니다.\n")
                        return
                    }
                    
                    // 아바타 가격보다 가진 코인이 없다면,
                    if conCost > self.myCoin {
                        // print("아바타를 살 코인이 없습니다.")
                        let alert = PartnerLeftAlertView()
                        alert.configure(title: "아바타 구매 실패", description: "🪙 코인이 부족합니다.\n열심히 운동해서 코인을 모아주세요.")
                        alert.frame = self.view.bounds
                        self.view.addSubview(alert)
                        
                        // 확인 버튼 누르면 알림 제거
                        alert.confirmButton.rx.tap
                            .bind { [weak alert] in
                                alert?.removeFromSuperview()
                            }
                            .disposed(by: self.disposeBag)
                    } else {
                        
                        var selected = model
                        selected.isLocked = false
                        self.myCoin = self.myCoin - conCost
                        
                        // 사용자 DB에 잔액 업데이트
                        FirestoreService.shared.updateDocument(collectionName: "users", documentName: self.uid, fields: ["coin": self.myCoin])
                            .subscribe(
                                onSuccess: {
                                    print("잔액 업데이트 성공\n")
                                }, onFailure: { error in
                                    print("잔액 업데이트 실패 : \(error)\n")
                                }
                            ).disposed(by: self.disposeBag)
                        
                        // 상점 coin 라벨 업데이트
                        self.rootView.coinLabel.text = "\(self.myCoin)"
                        
                        // selected의 타입과 이미지 이름을 안전하게 꺼냄
                        guard let type = selected.type,
                              let imageName = selected.imageName else { return }

                        // 전체 아바타 리스트에서 해당 모델 갱신
                        var updated = self.viewModel.allAvatarsRelay.value
                        if let index = updated.firstIndex(where: { $0.type == selected.type }) {
                            updated[index] = selected
                        }
                        self.viewModel.allAvatarsRelay.accept(updated)
                        
                        // Firestore에 해금 정보만 저장 (대표 아바타 저장 )
                        FirestoreService.shared.saveUnlockedAvatar(uid: self.uid, newType: type)
                        
                        // UI 미리보기만 업데이트 (선택 아바타는 그대로 유지)
                        if let image = UIImage(named: imageName),
                           let cgImage = image.cgImage {
                            let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                            let flipped = UIImage(cgImage: fixed.cgImage!, scale: fixed.scale, orientation: .upMirrored)
                            self.rootView.selectedAvatarImg.image = flipped
                        }
                        
                        self.rootView.avatarNameStack.updateNickname(selected.avatarName)
                        
                        // Firestore에 해금 정보 + 대표 아바타 저장
                        FirestoreService.shared.saveUnlockedAvatar(uid: self.uid, newType: type)
                        _ = FirestoreService.shared.saveSelectedAvatar(uid: self.uid, type: type) // 리턴값 무시하여 노란 오류 제거
                      
                        // 아바타 목록 새로고침 (잠금 해제 반영)
                        self.viewModel.fetchAvatars(uid: self.uid)
                    }
                }
                popup.onCancel = {
                    print("구매 취소")
                }
                self.present(popup, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 미리보기 아바타 UI 반영
        viewModel.selectedPreviewAvatarRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] model in
                guard let self,
                      let imageName = model.imageName,
                      let image = UIImage(named: imageName),
                      let cgImage = image.cgImage else { return }

                let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                let flipped = UIImage(cgImage: fixed.cgImage!, scale: fixed.scale, orientation: .upMirrored)
                self.rootView.selectedAvatarImg.image = flipped

                self.rootView.avatarNameStack.updateNickname(model.avatarName)

                let currentType = self.viewModel.currentAvatarTypeRelay.value
                self.rootView.changeButton.isHidden = !model.isUnlocked || model.type == currentType
            })
            .disposed(by: disposeBag)
        
        // 진짜 선택된 아바타 반영 → UI 업데이트 + Firestore 저장
        viewModel.selectedAvatarRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] model in
                guard let self,
                      let imageName = model.imageName,
                      let image = UIImage(named: imageName),
                      let cgImage = image.cgImage else { return }

                let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                let flipped = UIImage(cgImage: fixed.cgImage!, scale: fixed.scale, orientation: .upMirrored)
                self.rootView.selectedAvatarImg.image = flipped

                self.rootView.avatarNameStack.updateNickname(model.avatarName)

                if model.isUnlocked, let type = model.type {
                    _ = FirestoreService.shared.saveSelectedAvatar(uid: self.uid, type: type)
                }

                self.rootView.avatarCollection.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 진짜 아바타 기준 → 변경 버튼 상태 처리
        viewModel.selectedAvatarRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] model in
                guard let self else { return }
                let currentType = self.viewModel.currentAvatarTypeRelay.value
                self.rootView.changeButton.isHidden = !model.isUnlocked || model.type == currentType
            }
            .disposed(by: disposeBag)
        
        // 대표 아바타 변경 버튼 탭 → 확정된 선택 처리
        rootView.changeButton.rx.tap
            .withLatestFrom(viewModel.selectedPreviewAvatarRelay.compactMap { $0 }) // 최신 선택값 기준
            .subscribe(onNext: { [weak self] selected in
                guard let self else { return }
                guard let type = selected.type else { return }
                
                // 메인뷰나 마이페이지 전역 상태 업데이트
                AvatarManager.shared.updateAvatar(uid: self.uid, avatarType: type)
                
                // 대표 아바타 갱신
                self.viewModel.currentAvatarTypeRelay.accept(selected.type)
                self.viewModel.selectedAvatarRelay.accept(selected)
                
                // 미리보기도 일치시키기
                self.viewModel.selectedPreviewAvatarRelay.accept(selected)
                
                // 셀 선택 UI 반영
                if let index = self.viewModel.currentFilteredAvatarsRelay.value.firstIndex(where: { $0.type == selected.type }) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.rootView.avatarCollection.selectItem(at: indexPath, animated: true, scrollPosition: [])
                }
            })
            .disposed(by: disposeBag)
        
        
        // 전역 상태가 바뀌었을 때 → 뷰모델에도 반영 (다른 화면에서 변경 시 대응)
        AvatarManager.shared.selectedAvatarRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newType in
                guard let self else { return }
                
                let currentType = self.viewModel.selectedAvatarRelay.value?.type
                if currentType != newType,
                   let model = self.viewModel.allAvatarsRelay.value.first(where: { $0.type == newType }) {
                    self.viewModel.selectedAvatarRelay.accept(model)
                    self.viewModel.selectedPreviewAvatarRelay.accept(model)
                } else {
                    print("이미 선택된 아바타와 동일")
                }
            })
            .disposed(by: disposeBag)
    }

    // 카테고리 셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == rootView.categoryCollectionView {
            let width: CGFloat = floor(collectionView.frame.width / CGFloat(filteredTypes.count))
            return CGSize(width: width, height: 40)
        } else {
            return CGSize(width: 100, height: 100)
        }
    }
    
    /// 사용자 코인 정보 가져오기
    private func fetchMyCoin(uid: String) {
        // DB 에서 사용자 uid 로 coin 정보 가져오기
        FirestoreService.shared.fetchDocument(collectionName: "users", documentName: uid)
            .subscribe(
                onSuccess: { [weak self] data in
                    guard let self else { return }
                    guard let coin = data["coin"] as? Int else {
                        print("Error : 코인 데이터 가져오기 실패\n")
                        return
                    }
                    // print("코인 : \(coin)") // 디버깅용
                    
                    myCoin = coin
                    //print("현재 나의 코인 : \(myCoin)\n")
                    
                    // 코인 라벨에 사용자 코인 출력하기
                    self.rootView.coinLabel.text = "\(coin)"
                }
            ).disposed(by: disposeBag)
    }
}
