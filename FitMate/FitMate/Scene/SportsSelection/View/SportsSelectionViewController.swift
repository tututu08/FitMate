import UIKit
import RxRelay
import RxSwift
import SnapKit

class SportsSelectionViewController: BaseViewController {
    private let selectedItemRelay = PublishRelay<CarouselViewModel.ExerciseItem>()
    let carouselViewModel = CarouselViewModel()
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "운동 선택"
        return label
    }()
    let collectionView: UICollectionView = {
        let layout = UPCarouselFlowLayout()
        
        layout.scrollDirection = .vertical   // 세로 스크롤
        layout.itemSize = CGSize(width: 355, height: 266)
        layout.sideItemScale = 0.7            // 옆에 있는 셀 크기 비율
        layout.sideItemAlpha = 0.6            // 옆에 있는 셀 투명도
        layout.sideItemShift = 10             // 셀의 좌우(세로 스크롤일 경우 좌우) 이동량
        layout.spacingMode = .fixed(spacing: -45)  // 셀 간격


        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemBlue
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        // 뷰 레이아웃 완료 후 (비동기 실행)
        DispatchQueue.main.async { [weak self] in
            // 중간 인덱스로 스크롤 위치 이동 (무한 스크롤용 초기 위치)
            self?.scrollToMiddle()
        }
        view.backgroundColor = .darkGray
    }

    override func configureUI() {
        super.configureUI()
        view.addSubview(label)
        view.addSubview(collectionView)
        label.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
         
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(44)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        let input = CarouselViewModel.Input()
        let output = carouselViewModel.transform(input: input)

        output.items
            .drive(collectionView.rx.items(
                cellIdentifier: "cell", cellType: CarouselCell.self)
            ) { index, item, cell in
                cell.configureCell(with: item)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(CarouselViewModel.ExerciseItem.self)
            .bind(onNext: { [weak self] item in
                self?.selectedItemRelay.accept(item)
            })
            .disposed(by: disposeBag)
        
        selectedItemRelay
            .bind(onNext: { [weak self] item in
                let modeVC = SportsModeViewController(exerciseItem: item)
                self?.navigationController?.pushViewController(modeVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // 무한 스크롤 초기 위치를 배열 중간으로 설정하는 함수
    private func scrollToMiddle() {
        // 레이아웃 캐스팅
        guard let layout = collectionView.collectionViewLayout as? UPCarouselFlowLayout else { return }

        // 아이템 높이, 간격 계산
        let itemHeight = layout.itemSize.height
        let spacing = layout.minimumLineSpacing
        let totalHeight = itemHeight + spacing

        // 중간 인덱스 (원본 아이템 개수)
        let middleIndex = carouselViewModel.originalCount
        // 중간 인덱스 위치로 offsetY 계산
        let offsetY = CGFloat(middleIndex) * totalHeight - (collectionView.bounds.height / 2) + (itemHeight / 2)

        // 위치 이동 (애니메이션 없이)
        collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
    }
}
