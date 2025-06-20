
import UIKit
import SnapKit

final class HistoryView: UIView {

    let categoryUnderlineView = UIView()

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

    let recordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "운동 기록"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
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

        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
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

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(categoryCollectionView)
        addSubview(categoryUnderlineView)
        addSubview(recordCollectionView)
        addSubview(contentLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(12)
            $0.centerX.equalToSuperview()
        }

        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
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
        
        contentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalTo(categoryUnderlineView.snp.bottom).offset(180)
        }
    }
}
