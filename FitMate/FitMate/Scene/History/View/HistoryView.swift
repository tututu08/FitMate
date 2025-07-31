
import UIKit
import SnapKit

final class HistoryView: UIView {

    let topBar = UIView() //상단 바

    // 화면 제목 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "운동 기록"
        label.textColor = .background0
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        return label
    }()

    // 카테고리 하다 언더라인(보라줄) 뷰
    let categoryUnderlineView = UIView()

    // 카테고리 선택용 컬렉션뷰
    let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // 운동기록을 세로로 스크롤하는 컬렉션뷰
    let recordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // 기록이 없을 때 표시되는 안내 문구
    let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "기록이 없습니다"
        label.font = UIFont(name: "DungGeunMo", size: 20)
        label.textColor = .background500
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "Background800")

        // 카테고리 셀 등록
        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        
        //기록카드 셀 등록
        recordCollectionView.register(WalkRecordCell.self, forCellWithReuseIdentifier: WalkRecordCell.identifier)
        recordCollectionView.register(JumpRopeRecordCell.self, forCellWithReuseIdentifier: JumpRopeRecordCell.identifier)
        recordCollectionView.register(BicycleRecordCell.self, forCellWithReuseIdentifier: BicycleRecordCell.identifier)
        recordCollectionView.register(RunRecordCell.self, forCellWithReuseIdentifier: RunRecordCell.identifier)
        recordCollectionView.register(PlankRecordCell.self, forCellWithReuseIdentifier: PlankRecordCell.identifier)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // 전체 레이아웃 설정
    private func setupLayout() {
        addSubview(topBar)
        topBar.addSubview(titleLabel)

        addSubview(categoryCollectionView)
        addSubview(categoryUnderlineView)
        addSubview(recordCollectionView)
        addSubview(contentLabel)

        topBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        categoryUnderlineView.backgroundColor = UIColor(named: "Primary500")
        categoryUnderlineView.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        recordCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryUnderlineView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(categoryUnderlineView.snp.bottom).offset(180)
            $0.centerX.equalToSuperview()
        }
    }
}
