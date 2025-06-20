import UIKit
import SnapKit

final class WorkRecordCell: UICollectionViewCell {
    static let identifier = "WorkRecordCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let characterImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private let characterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "종목명"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "총기록"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let unitLabel: UILabel = {
        let label = UILabel()
        label.text = "단위"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(144)
            $0.width.equalTo(335)
        }

        characterImageView.addSubview(characterImage)
        characterImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(88)
            $0.height.equalTo(88)
        }

        let infoStack = UIStackView(arrangedSubviews: [typeLabel, totalLabel, unitLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4

        let containerStack = UIStackView(arrangedSubviews: [characterImageView, infoStack])
        containerStack.axis = .horizontal
        containerStack.spacing = 12
        containerStack.alignment = .center

        cardView.addSubview(containerStack)
        containerStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        characterImageView.snp.makeConstraints {
            $0.width.equalTo(144)
            $0.height.equalTo(112)
        }
    }

    func configure(with record: WorkoutRecord) {
        typeLabel.text = record.type
        totalLabel.text = record.totalDistance
        unitLabel.text = record.unit

        switch record.type {
        case "걷기":
            characterImage.image = UIImage(named: "walk")
        case "달리기":
            characterImage.image = UIImage(named: "run")
        case "자전거":
            characterImage.image = UIImage(named: "bicycle")
        case "줄넘기":
            characterImage.image = UIImage(named: "jumpRope")
        case "플랭크":
            characterImage.image = UIImage(named: "plank")
        default:
            characterImage.image = nil
        }
    }
}
