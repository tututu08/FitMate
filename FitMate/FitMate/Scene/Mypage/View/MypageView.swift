
import UIKit
import SnapKit

final class MypageView: UIView {

    //설정버튼
    let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.tintColor = .white
        return button
    }()
    //뒤로가기버튼
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "backButton"), for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    // 상단 바
    let topBar = UIView()

    // 상단 타이틀 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    // 프로필 이미지 배경
    private let profileImageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Secondary50")
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    // 프로필 이미지 뷰
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kaepy")
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageView.clipsToBounds = true
        return imageView
    }()

    //닉네임 라벨
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    //프로필 아래 배치되는 언더라인
    private let underline: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Primary500")
        return view
    }()

    let scrollView = UIScrollView() //전체 스크롤뷰
    let contentView = UIView()//스크롤 뷰 내부의 컨텐츠뷰

    // 업적 타이틀 라벨
    let achievementTitle: UILabel = {
        let label = UILabel()
        label.text = "달성한 업적"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    //업적 더보기버튼
    let achievementMoreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .white
        return button
    }()

    // 업적타이틀 + 더보기버튼 수평스택
    lazy var achievementTitleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [achievementTitle, achievementMoreButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    //업적 이미지
    let achievementImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        return view
    }()

    
    //누적 기록 타이틀 라벨
    let levelTitle: UILabel = {
        let label = UILabel()
        label.text = "누적 기록"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    // 누적기록 컬렉션 뷰
    let recordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    //기록이 없을 경우 표시되는 라벨
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "기록이 없습니다"
        label.font = UIFont(name: "DungGeunMo", size: 20)
        label.textColor = .background500
        return label
    }()

    // 설정버튼이랑 타이틀 설정을 위한 초기화 이닛
    convenience init(showSettingButton: Bool = true, titleText: String = "", showBackButton: Bool = true) {
        self.init(frame: .zero)
        settingButton.isHidden = !showSettingButton
        backButton.isHidden = !showBackButton
        titleLabel.text = titleText
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .background800
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 전체 레이아웃 구성
    private func setupLayout() {
        addSubview(topBar)
        addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(underline)
        contentView.addSubview(contentLabel)

        topBar.addSubview(titleLabel)
        topBar.addSubview(settingButton)
        topBar.addSubview(backButton)

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [achievementTitleStack, achievementImageView, levelTitle, recordCollectionView].forEach {
            contentView.addSubview($0)
        }

        topBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        settingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }

        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }

        profileImageContainer.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(64)
        }

        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }

        nicknameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageContainer.snp.centerY)
            $0.leading.equalTo(profileImageContainer.snp.trailing).offset(16)
        }

        underline.snp.makeConstraints {
            $0.top.equalTo(profileImageContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(underline.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(recordCollectionView.snp.bottom)
        }

        achievementTitleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        achievementImageView.snp.makeConstraints {
            $0.top.equalTo(achievementTitleStack.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(72)
        }

        levelTitle.snp.makeConstraints {
            $0.top.equalTo(achievementImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        recordCollectionView.snp.makeConstraints {
            $0.top.equalTo(levelTitle.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(700)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(levelTitle.snp.bottom).offset(100)
            $0.center.equalToSuperview()
        }

        // 현재 업적관련은 완료되지 않아서 숨김처리 해둠
        achievementTitleStack.isHidden = true
        achievementImageView.isHidden = true

        // 업적이 없을 때 누적위치 조정(업적 들어가면 이후에 지워야함)
        levelTitle.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
