import UIKit
import SnapKit

final class MypageView: UIView {

    let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "backButton"), for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    let topBar = UIView()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "KappyAlone")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor(named: "Secondary50")
        imageView.layer.cornerRadius = 4
        return imageView
    }()

    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    private let underline: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Primary500")
        return view
    }()

    let scrollView = UIScrollView()
    let contentView = UIView()

    let achievementTitle: UILabel = {
        let label = UILabel()
        label.text = "달성한 업적"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    let achievementMoreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .white
        return button
    }()

    lazy var achievementTitleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [achievementTitle, achievementMoreButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    let achievementImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        return view
    }()

    let levelTitle: UILabel = {
        let label = UILabel()
        label.text = "운동 레벨"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

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

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "기록이 없습니다"
        label.font = UIFont(name: "DungGeunMo", size: 20)
        label.textColor = .background500
        return label
    }()

    // ✅ 백버튼 제어 가능한 이니셜라이저
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

    private func setupLayout() {
        addSubview(topBar)
        addSubview(profileImageView)
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

        profileImageView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(64)
        }

        nicknameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView.snp.centerY)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }

        underline.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(16)
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
            $0.top.equalTo(levelTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(700)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(levelTitle.snp.bottom).offset(100)
            $0.center.equalToSuperview()
        }

        achievementTitleStack.isHidden = true
        achievementImageView.isHidden = true

        levelTitle.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
