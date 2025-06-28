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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.categoryCollectionView.delegate = self

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

    private func bindAvatarViewModel() {
        // 추가 예정..
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
