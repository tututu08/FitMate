
import UIKit
import RxSwift
import RxCocoa

final class HistoryViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    private let rootView = HistoryView()
    private let viewModel = HistoryViewModel()
    private let disposeBag = DisposeBag()

    //선택된 운동 카테고리를 외부로 방출하는 PublishSubject( 카테고리 컬렉션뷰 선택 이벤트를 뷰모델로 전달하기 위해 사용함 )
    private let selectedCategorySubject = PublishSubject<ExerciseType>()
    private let uid: String

    // 표시할 카테고리
    private let filteredTypes: [ExerciseType] = ExerciseType.allCases

    init(uid: String) {
        self.uid = uid
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 루트 뷰 설정
    override func loadView() {
        self.view = rootView
    }

    // 네이게이션 바 숨김처리
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //컬렉션뷰 설정
        rootView.recordCollectionView.delegate = self
        rootView.recordCollectionView.dataSource = self
        rootView.categoryCollectionView.delegate = self

        viewModel.loadRemoteData(uid: uid) // 데이터 가져오기
        bindViewModel() //Rx바인딩

        //초기 선택 인덱스(전체로 설정)
        let initialIndexPath = IndexPath(item: 0, section: 0)
        rootView.categoryCollectionView.selectItem(at: initialIndexPath, animated: false, scrollPosition: [])
        selectedCategorySubject.onNext(filteredTypes[0])
    }

    private func bindViewModel() {
        // 카테고리 목록 바인딩
        Observable.just(filteredTypes)
            .bind(to: rootView.categoryCollectionView.rx.items(
                cellIdentifier: CategoryCell.identifier,
                cellType: CategoryCell.self)
            ) { [weak self] index, type, cell in
                cell.configure(with: type.rawValue)
                //현재 선택된 카테고리와 비교해서 셀 선택상태를 설정시킴
                let currentSelected = try? self?.viewModel.currentFilteredRecords.first?.type
                cell.isSelected = (type == currentSelected)
            }
            .disposed(by: disposeBag)

        // 카테고리 선택시 subject에 선택된 운동 타입을 방출시킴
        rootView.categoryCollectionView.rx.itemSelected
            .map { [weak self] indexPath -> ExerciseType in
                guard let self = self else { return .all }
                return self.filteredTypes[indexPath.item]
            }
            .bind(to: selectedCategorySubject)
            .disposed(by: disposeBag)

        //뷰모델 인풋 아웃풋 바인딩
        let input = HistoryViewModel.Input(selectedCategory: selectedCategorySubject.asObservable())
        let output = viewModel.transform(input: input)

        // 운동 기록을 필터링한 결과를 받아서 업데이트시킴
        output.filteredRecords
            .drive(onNext: { [weak self] records in
                print("ViewController: reload 호출됨, \(records.count)건")
                self?.rootView.recordCollectionView.reloadData()
                self?.rootView.contentLabel.isHidden = !records.isEmpty
            })
            .disposed(by: disposeBag)
    }

    // 셀 크기 설정
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

// 운동 기록 표시를 위한 데이터소스
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
            
        case .plank:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlankRecordCell.identifier, for: indexPath) as! PlankRecordCell
            cell.configure(with: record)
            return cell
        default:
        #if DEBUG // DEBUG 환경에서만 경고를 출력
            // assertionFailure는 콘솔에 오류 메시지를 출력하고 중단(breakpoint)함.
            assertionFailure("정의되지 않은 운동 타입: \(record.type)")
        #endif
            return UICollectionViewCell()
        }
    }
}
