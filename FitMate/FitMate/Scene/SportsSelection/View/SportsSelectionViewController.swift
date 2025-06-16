import UIKit
import RxRelay
import RxSwift
import SnapKit

class SportsSelectionViewController: BaseViewController {
    
    // 선택된 운동 아이템을 전달하기 위한 Relay (다음 화면으로 전송할 때 사용)
    private let selectedItemRelay = PublishRelay<CarouselViewModel.ExerciseItem>()
    
    // Carousel 뷰에 연결될 ViewModel
    private let carouselViewModel = CarouselViewModel()
    
    private let uid: String // 로그인 유저의 uid 의존성 주입
    
    init(uid: String) {
        self.uid = uid // 외부에서 의존성 주입
        print("uid : \(uid)")
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 운동 목록을 표시하는 CollectionView (UPCarouselFlowLayout 사용)
    private let collectionView: UICollectionView = {
        let layout = UPCarouselFlowLayout()
        layout.scrollDirection = .vertical             // 세로 스크롤
        layout.itemSize = CGSize(width: 355, height: 266) // 셀 크기 설정
        layout.sideItemScale = 0.85                     // 양옆 아이템 크기 축소 비율
        layout.sideItemAlpha = 0.6                     // 양옆 아이템 투명도
        layout.sideItemShift = 10                      // 셀 이동 오프셋 (약간 겹치게 표현)
        layout.spacingMode = .fixed(spacing: -10)      // 셀 간 간격 설정
        
        // 설정한 레이아웃을 바탕으로 CollectionView 생성
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .background800
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""  // 뒤로가기 버튼 타이틀 제거
        self.title = "운동 선택"
        navigationController?.navigationBar.applyCustomAppearance()
        
        // 레이아웃 완료 후 무한 스크롤용 중간 위치로 스크롤
        DispatchQueue.main.async { [weak self] in
            self?.scrollToMiddle()
        }
        view.backgroundColor = .background800
    }

    // UI 요소 배치 설정
    override func configureUI() {
        super.configureUI()
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.width.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
    }

    // ViewModel과 바인딩
    override func bindViewModel() {
        super.bindViewModel()
        
        let input = CarouselViewModel.Input()  // 현재는 입력 없음
        let output = carouselViewModel.transform(input: input)

        // ViewModel에서 전달받은 운동 아이템을 CollectionView에 바인딩
        output.items
            .drive(collectionView.rx.items(
                cellIdentifier: "cell", cellType: CarouselCell.self)
            ) { index, item, cell in
                // 셀 구성 (각 셀에 데이터 적용)
                cell.configureCell(with: item)
            }
            .disposed(by: disposeBag)
        
        // 사용자가 셀을 선택하면 선택된 아이템을 selectedItemRelay로 전달
        collectionView.rx.modelSelected(CarouselViewModel.ExerciseItem.self)
            .bind(onNext: { [weak self] item in
                self?.selectedItemRelay.accept(item)
            })
            .disposed(by: disposeBag)
        
        // 선택된 아이템이 Relay를 통해 전달되면 다음 화면으로 이동
        selectedItemRelay
            .bind(onNext: { [weak self] item in
                guard let self else { return }
                // 선택된 운동 아이템을 전달하여 SportsModeViewController로 push
                let modeVC = SportsModeViewController(exerciseItem: item, uid: self.uid)
                self.navigationController?.pushViewController(modeVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // 무한 스크롤 효과를 위한 중간 인덱스로 초기 위치 이동
    private func scrollToMiddle() {
        guard let layout = collectionView.collectionViewLayout as? UPCarouselFlowLayout else { return }

        // 셀 높이와 셀 간 간격을 더한 총 높이
        let itemHeight = layout.itemSize.height
        let spacing = layout.minimumLineSpacing
        let totalHeight = itemHeight + spacing

        // 중간 인덱스 (반복된 배열 중간 위치)
        let middleIndex = carouselViewModel.originalCount

        // 해당 인덱스가 컬렉션 뷰 중앙에 오도록 offset 계산
        let offsetY = CGFloat(middleIndex) * totalHeight
                     - (collectionView.bounds.height / 2)
                     + (itemHeight / 2)

        // offset 적용 (애니메이션 없이)
        collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
    }
}
