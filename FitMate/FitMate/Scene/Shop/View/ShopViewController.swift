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
    private let uid: String
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
        let selectedAvatarInfo = viewModel.selectedAvatarRelay
            .compactMap { $0 } // 옵셔널 → 언랩
        
        let output = viewModel.transform(input: input)
        //아바타 목록 → CollectionView 바인딩
        output.selectedAvatar
            .drive(rootView.avatarCollection.rx.items(
                cellIdentifier: AvatarCell.id,
                cellType: AvatarCell.self
            )) { [weak self] index, model, cell in
                guard let self else { return }
                cell.configure(with: model)
                
                // 최초 진입 시 selectedAvatarRelay에 값이 없으면 자동 선택 -> ex: 캐피
                if self.viewModel.selectedAvatarRelay.value == nil {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.rootView.avatarCollection.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    self.viewModel.selectedAvatarRelay.accept(model)
                    
                    if let image = UIImage(named: model.imageName),
                       let cgImage = image.cgImage {
                        let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                        let flipped = UIImage(cgImage: fixed.cgImage!, scale: fixed.scale, orientation: .upMirrored)
                        self.rootView.selectedAvatarImg.image = flipped
                    }
                    
                    self.rootView.avatarNameStack.updateNickname(model.avatarName)
                    
//                    // 최초 진입 시에도 저장
//                    FirestoreService.shared.saveSelectedAvatar(uid: self.uid, type: model.type, mateUid: self.mateUid)
                }
            }
            .disposed(by: disposeBag)
        
        // 유저가 아바타 셀을 선택 → 선택된 아바타 반영
        rootView.avatarCollection.rx.modelSelected(AvatarModel.self)
            .bind(to: viewModel.selectedAvatarRelay)
            .disposed(by: disposeBag)
        
        //  선택된 아바타 → UI 업데이트 + Firestore 저장
        viewModel.selectedAvatarRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] (model: AvatarModel) in // 명시적으로 타입 지정
                guard let self else { return }
                
                if let image = UIImage(named: model.imageName),
                   let cgImage = image.cgImage {
                    let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                    let flipped = UIImage(cgImage: fixed.cgImage!, scale: fixed.scale, orientation: .upMirrored)
                    self.rootView.selectedAvatarImg.image = flipped
                }
                
                self.rootView.avatarNameStack.updateNickname(model.avatarName)
                
                // 해금된 아바타만 Firestore에 저장
                if model.isUnlocked {
                    FirestoreService.shared.saveSelectedAvatar(uid: self.uid, type: model.type, mateUid: self.mateUid)
                }
                
                self.rootView.avatarCollection.reloadData()
            })
            .disposed(by: disposeBag)
        
        
        viewModel.selectedAvatarRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] model in
                guard let self else { return }
                
                // 버튼 노출 조건
                let currentSelectedType = self.viewModel.currentAvatarTypeRelay.value
                self.rootView.changeButton.isHidden = !model.isUnlocked || model.type == currentSelectedType
            }
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
                
                let popup = AvatarPopUpViewController(
                    alertType: .avatarPurchase(
                        name: model.avatarName,
                        cost: model.conCost ?? 0
                    )
                )
                popup.configure(avatarImageName: model.imageName, coinCost: model.conCost ?? 0)
                
                popup.onConfirm = {
                    var selected = model
                    selected.isUnlocked = true
                    
                    var updated = self.viewModel.allAvatarsRelay.value
                    if let index = updated.firstIndex(where: { $0.type == selected.type }) {
                        updated[index] = selected
                    }
                    self.viewModel.allAvatarsRelay.accept(updated)
                    
                    if let image = UIImage(named: selected.imageName),
                       let cgImage = image.cgImage {
                        let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                        let flipped = UIImage(cgImage: fixed.cgImage!, scale: fixed.scale, orientation: .upMirrored)
                        self.rootView.selectedAvatarImg.image = flipped
                    }
                    
                    self.viewModel.selectedAvatarRelay.accept(selected)
                    
                    // Firestore에 해금 정보 + 대표 아바타 저장
                    FirestoreService.shared.saveUnlockedAvatar(uid: self.uid, newType: selected.type)
                    FirestoreService.shared.saveSelectedAvatar(
                        uid: self.uid, type: selected.type, mateUid: self.mateUid)
                    
                    self.viewModel.fetchAvatars(uid: self.uid)
                }
                popup.onCancel = {
                    print("구매 취소")
                }
                self.present(popup, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 대표 아바타 타입이 업데이트되면 해당 아바타를 selected로 자동 반영
        viewModel.currentAvatarTypeRelay
            .compactMap { $0 }
            .withLatestFrom(viewModel.allAvatarsRelay) { selectedType, avatars in
                avatars.first(where: { $0.type == selectedType })
            }
            .compactMap { $0 }
            .bind(to: viewModel.selectedAvatarRelay)
            .disposed(by: disposeBag)
        
        rootView.changeButton.rx.tap
            .withLatestFrom(selectedAvatarInfo) // 현재 선택된 아바타 모델
            .subscribe(onNext: { [weak self] selected in
                guard let self else { return }

                /// : Firestore + 전역 상태 갱신
                AvatarManager.shared.updateAvatar(
                    uid: self.uid,
                    avatarType: selected.type,
                    mateUid: self.mateUid
                )
                /// 선택된 아바타 기준 체인지 버튼 보이게 안보이게
                self.viewModel.currentAvatarTypeRelay.accept(selected.type)
                self.viewModel.selectedAvatarRelay.accept(selected)
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
}
