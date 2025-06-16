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
    
    // 로그인 유저의 uid
    private let uid: String
    
    // 초기화 함수
    init(uid: String) {
        self.uid = uid // 의존성 주입
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
