
import UIKit
import SnapKit

final class MypageView: UIView {

    let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.tintColor = .white
        return button
    }()

    let topBar: UIView = {
        let view = UIView()
        return view
    }()

    let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        return view
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
        view.backgroundColor = UIColor(red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
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
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
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
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [achievementTitleStack, achievementImageView, levelTitle, recordCollectionView].forEach {
            contentView.addSubview($0)
        }

        let titleLabel = UILabel()
        titleLabel.text = "마이페이지"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        topBar.addSubview(titleLabel)
        topBar.addSubview(settingButton)

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(87)
            $0.height.equalTo(28)
        }

        settingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }

        topBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
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
            $0.bottom.equalToSuperview()
        }
    }
}
