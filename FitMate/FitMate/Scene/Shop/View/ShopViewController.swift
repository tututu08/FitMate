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

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        rootView.categoryCollectionView.delegate = self

        viewModel.fetchAvatars()
        bindCategoryViewModel()

        let initialIndexPath = IndexPath(item: 0, section: 0)
        rootView.categoryCollectionView.selectItem(at: initialIndexPath, animated: false, scrollPosition: [])
        selectedCategorySubject.onNext(filteredTypes[0])
    }

    // 반복적인 delegate proxy 충돌
    // 방지를 위해 카테고리와 아바타 컬렉션 Rx 바인딩 시점 조절
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bindAvatarViewModel()
    }
    
    // 카테고리 컬렉션뷰 바인딩
    private func bindCategoryViewModel() {
        Observable.just(filteredTypes)
            .bind(to: rootView.categoryCollectionView.rx.items(
                cellIdentifier: ShopCategoryCell.id,
                cellType: ShopCategoryCell.self)
            ) { [weak self] index, type, cell in
                let currentSelected = try? self?.viewModel.selectedCategoryRelay.value
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
    
    // 아바타 컬렉션뷰 바인딩
    private func bindAvatarViewModel() {
        let input = ShopViewModel.Input(
            selectedCategory: selectedCategorySubject.asObservable(),
            selectedAvatar: rootView.avatarCollection.rx.modelSelected(AvatarModel.self).asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        /// 출력된 아바타 목록을 컬렉션 뷰에 바인딩
        output.selectedAvatar
            .drive(rootView.avatarCollection.rx.items(
                cellIdentifier: AvatarCell.id,
                cellType: AvatarCell.self
            )) { [weak self] index, model, cell in
                // 셀 타입을 AvatarCell로 안전하게 캐스팅한 후 configure 호출
//                if let avatarCell = cell as? AvatarCell {
//                    avatarCell.configure(with: model)
//                }
                cell.configure(with: model)

                /// 앱 진입 시 처음으로 보여줄 기본 선택 아바타를  캐피로 지정
                if model.type == .kaepy,
                   self?.viewModel.selectedAvatarRelay.value == nil {
                    // 해당 인덱스의 셀을 선택된 상태로 만들어줌
                    let indexPath = IndexPath(item: index, section: 0)
                    self?.rootView.avatarCollection.selectItem(
                        at: indexPath,
                        animated: false,
                        scrollPosition: [])
                    // 뷰모델에 선택된 아바타를 전달 → 상태 저장
                    self?.viewModel.selectedAvatarRelay.accept(model)
                    // 상단 대표 이미지에 선택된 아바타 이미지 반영
                    if let image = UIImage(named: model.imageName),
                       let cgImage = image.cgImage {
                        let fixedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                        let flippedImage = UIImage(cgImage: fixedImage.cgImage!, scale: fixedImage.scale, orientation: .upMirrored)
                        self?.rootView.selectedAvatarImg.image = flippedImage
                    }
                }
            }
            .disposed(by: disposeBag)

        // 유저 선택 → 뷰모델 반영
        rootView.avatarCollection.rx.modelSelected(AvatarModel.self)
            .bind(to: viewModel.selectedAvatarRelay)
            .disposed(by: disposeBag)

        /// 선택된 아바타들 UI에 반영
        viewModel.selectedAvatarRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            // 대표 이미지 뷰에 새롭게 선택된 아바타 이미지로 갱신
            .bind { [weak self] model in
                // selectedAvatarImg는 에셋에서 이미지 가져오고 있음
                if let image = UIImage(named: model.imageName),
                   let cgImage = image.cgImage {
                    // 그래서 원본 -> 파베 등록된 이미지(디자이너님 공유)로 반전시켜야 함
                    let fixedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                    let flippedImage = UIImage(cgImage: fixedImage.cgImage!, scale: fixedImage.scale, orientation: .upMirrored)
                    self?.rootView.selectedAvatarImg.image = flippedImage
                }
            }
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
