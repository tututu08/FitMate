import UIKit
import SnapKit

final class PlankRecordCell: UICollectionViewCell {
    static let identifier = "PlankRecordCell"

    // 기록을 담기 위한 배열
    private var detailLabels: [UILabel] = []

    // 캐릭터이미지
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "plank")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()

    // 플랭크
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "플랭크"
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    // 날짜
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "0000.00.00"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()

    // 결과
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "협력-성공"
        label.font = .systemFont(ofSize: 12)
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

    // 전체 셀 설정
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
            makeDetailLabel(value: "0", unit: "목표(분)"),
            makeDetailLabel(value: "0", unit: "나(분)"),
            makeDetailLabel(value: "0", unit: "메이트(분)")
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

    // 셀 기록을 구성하는 라벨스택들
    private func makeDetailLabel(value: String, unit: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 20)
        valueLabel.textColor = .black
        valueLabel.textAlignment = .left
        valueLabel.snp.makeConstraints { $0.height.equalTo(31) }

        detailLabels.append(valueLabel) //configure에 값을 업데이트하기위해 배열저장

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

    // 데이터를 받아 셀 내용 구성
    func configure(with record: ExerciseRecord) {
        dateLabel.text = record.dateOnly
        resultLabel.text = record.result.rawValue

        resultLabel.backgroundColor = UIColor(named: "Primary500") // 플랭크는 대결이 없어서 색상 고정
        resultLabel.textColor = .white

        // 나, 메이트는 초 단위 -> 분단위 볍ㄴ환
        let me = Int(record.detail2) ?? 0
        let mate = Int(record.detail3) ?? 0

        // 목표치는 분단위라 그대로 사용
        let converted = [record.detail1,String(me / 60),String(mate / 60)]

        for (index, label) in detailLabels.enumerated() {
            guard index < converted.count else { break }
            label.text = converted[index]
        }
    }
}
