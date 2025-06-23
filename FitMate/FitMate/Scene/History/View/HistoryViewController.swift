
import UIKit
import RxSwift
import RxCocoa

final class HistoryViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    private let rootView = HistoryView()
    private let viewModel = HistoryViewModel()
    private let disposeBag = DisposeBag()

    private let selectedCategorySubject = PublishSubject<ExerciseType>()
    private let uid: String

    private let filteredTypes: [ExerciseType] = ExerciseType.allCases.filter { $0 != .plank }

    init(uid: String) {
        self.uid = uid
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = rootView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.recordCollectionView.delegate = self
        rootView.recordCollectionView.dataSource = self
        rootView.categoryCollectionView.delegate = self

        viewModel.loadRemoteData(uid: uid)
        bindViewModel()

        let initialIndexPath = IndexPath(item: 0, section: 0)
        rootView.categoryCollectionView.selectItem(at: initialIndexPath, animated: false, scrollPosition: [])
        selectedCategorySubject.onNext(filteredTypes[0])
    }

    private func bindViewModel() {
        Observable.just(filteredTypes)
            .bind(to: rootView.categoryCollectionView.rx.items(
                cellIdentifier: CategoryCell.identifier,
                cellType: CategoryCell.self)
            ) { [weak self] index, type, cell in
                cell.configure(with: type.rawValue)
                let currentSelected = try? self?.viewModel.currentFilteredRecords.first?.type
                cell.isSelected = (type == currentSelected)
            }
            .disposed(by: disposeBag)

        rootView.categoryCollectionView.rx.itemSelected
            .map { [weak self] indexPath -> ExerciseType in
                guard let self = self else { return .all }
                return self.filteredTypes[indexPath.item]
            }
            .bind(to: selectedCategorySubject)
            .disposed(by: disposeBag)

        let input = HistoryViewModel.Input(selectedCategory: selectedCategorySubject.asObservable())
        let output = viewModel.transform(input: input)

        output.filteredRecords
            .drive(onNext: { [weak self] records in
                print("ViewController: reload 호출됨, \(records.count)건")
                self?.rootView.recordCollectionView.reloadData()
                self?.rootView.contentLabel.isHidden = !records.isEmpty
            })
            .disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == rootView.recordCollectionView {
            let width = collectionView.frame.width - 32
            return CGSize(width: width, height: 120)
        } else {
            let width: CGFloat = floor(collectionView.frame.width / CGFloat(filteredTypes.count))
            return CGSize(width: width, height: 40)
        }
    }
}

extension HistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentFilteredRecords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let record = viewModel.currentFilteredRecords[indexPath.item]

        switch record.type {
        case .walk:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalkRecordCell.identifier, for: indexPath) as! WalkRecordCell
            cell.configure(with: record)
            return cell

        case .jumpRope:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JumpRopeRecordCell.identifier, for: indexPath) as! JumpRopeRecordCell
            cell.configure(with: record)
            return cell

        case .bicycle:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BicycleRecordCell.identifier, for: indexPath) as! BicycleRecordCell
            cell.configure(with: record)
            return cell

        case .run:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RunRecordCell.identifier, for: indexPath) as! RunRecordCell
            cell.configure(with: record)
            return cell

        default:
            fatalError("종목 없음")
        }
    }
}
