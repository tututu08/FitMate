
import UIKit
import SnapKit

final class BicycleRecordCell: UICollectionViewCell {
    static let identifier = "BicycleRecordCell"

    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bicycle")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "자전거"
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "0000.00.00"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "대결-패배"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.backgroundColor = UIColor(named: "Secondary400")
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        backgroundColor = .white
        layer.cornerRadius = 8
        clipsToBounds = true

        contentView.addSubview(characterImageView)
        characterImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(88)
        }

        resultLabel.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.width.greaterThanOrEqualTo(60)
        }

        let titleStack = UIStackView(arrangedSubviews: [typeLabel, dateLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 4
        titleStack.alignment = .center

        let headerStack = UIStackView(arrangedSubviews: [titleStack, resultLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.alignment = .center

        let detailStack = UIStackView(arrangedSubviews: [
            makeDetailLabel(value: "0", unit: "목표(km)"),
            makeDetailLabel(value: "0", unit: "나(km)"),
            makeDetailLabel(value: "0", unit: "메이트(km)")
        ])
        detailStack.axis = .horizontal
        detailStack.distribution = .equalSpacing
        detailStack.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [headerStack, detailStack])
        textStack.axis = .vertical
        textStack.spacing = 8

        contentView.addSubview(textStack)
        textStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalTo(characterImageView.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(14)
        }
    }

    private func makeDetailLabel(value: String, unit: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 20)
        valueLabel.textColor = .black
        valueLabel.textAlignment = .left
        valueLabel.snp.makeConstraints { $0.height.equalTo(31) }

        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = .systemFont(ofSize: 13)
        unitLabel.textColor = .gray
        unitLabel.textAlignment = .left
        unitLabel.snp.makeConstraints { $0.height.equalTo(21) }

        let stack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.snp.makeConstraints { $0.size.equalTo(CGSize(width: 70, height: 56)) }
        return stack
    }

    func configure(with record: ExerciseRecord) {
        dateLabel.text = record.date
        resultLabel.text = record.result.rawValue
    }
}
