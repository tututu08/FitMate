//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
//
//

import UIKit
import RxSwift
import RxCocoa

final class HistoryViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    private let rootView = HistoryView()
    private let viewModel = HistoryViewModel()
    private let disposeBag = DisposeBag()

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.recordCollectionView.delegate = self
        rootView.categoryCollectionView.delegate = self
        viewModel.loadMockData()
        bindViewModel()
        
        let initialIndexPath = IndexPath(item: 0, section: 0)
        rootView.categoryCollectionView.selectItem(at: initialIndexPath, animated: false, scrollPosition: [])
    }

    private func bindViewModel() {
        Observable.just(ExerciseType.allCases)
            .bind(to: rootView.categoryCollectionView.rx.items(
                cellIdentifier: CategoryCell.identifier,
                cellType: CategoryCell.self)
            ) { index, type, cell in
                cell.configure(with: type.rawValue)
                cell.isSelected = (type == self.viewModel.selectedCategory.value)
            }
            .disposed(by: disposeBag)

        rootView.categoryCollectionView.rx.itemSelected
            .map { ExerciseType.allCases[$0.item] }
            .bind(to: viewModel.selectedCategory)
            .disposed(by: disposeBag)

        viewModel.filteredRecords
            .drive(rootView.recordCollectionView.rx.items(
                cellIdentifier: RecordCell.identifier,
                cellType: RecordCell.self)
            ) { index, record, cell in
                cell.configure(with: record)
            }
            .disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == rootView.recordCollectionView {
            let width = collectionView.frame.width - 32
            return CGSize(width: width, height: 100)
        } else {
            let width: CGFloat = floor(collectionView.frame.width / CGFloat(ExerciseType.allCases.count))
            return CGSize(width: width, height: 40)
        }
    }
}
