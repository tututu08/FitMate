
import UIKit
import SnapKit

final class BicycleRecordCell: UICollectionViewCell {
    static let identifier = "BicycleRecordCell"

    // 상세 기록을 저장하는 배열. configure에서 index로 접근하게 설정
    private var detailLabels: [UILabel] = []
    
    // 캐릭터 이미지
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bicycle")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()

    // 자전거관련
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "자전거"
        label.font = UIFont(name: "Pretendard-Medium", size: 20)
        label.textColor = .background900
        return label
    }()

    // 날짜 표시용
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "0000.00.00"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = .background300
        return label
    }()

    // 운동 결과
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "대결-패배" // configure에서 갱신된다. 초기값은 그냥 넣어둠
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .background900
        label.backgroundColor = .secondary400 // configure에서 갱신된다.
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

    //셀 전체 레이아웃
    private func setupLayout() {
        backgroundColor = .background0
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

        // 셀 기록 영역 (목표, 나, 메이트 등)
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

    // 기록 구성하는 스택뷰 생성 함수
    private func makeDetailLabel(value: String, unit: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont(name: "Pretendard-SemiBold", size: 22)
        valueLabel.textColor = .background900
        valueLabel.textAlignment = .left
        valueLabel.snp.makeConstraints { $0.height.equalTo(31) }

        detailLabels.append(valueLabel) // detailLabels 배열에 저장해서 추후에 configure에서 접근시킴
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        unitLabel.textColor = .background600
        unitLabel.textAlignment = .left
        unitLabel.snp.makeConstraints { $0.height.equalTo(21) }

        let stack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.snp.makeConstraints { $0.size.equalTo(CGSize(width: 70, height: 56)) }
        return stack
    }

    // 실제 기록값을 기록영역에 반영
    func configure(with record: ExerciseRecord) {
        dateLabel.text = record.dateOnly
        resultLabel.text = record.result.rawValue
        
        // 결과타입(대결,협력)에 따라 색상 변경
        switch record.result {
        case .teamSuccess, .teamFail:
            resultLabel.backgroundColor = .primary500
            resultLabel.textColor = .background0
        case .versusWin, .versusLose:
            resultLabel.backgroundColor = .secondary400
            resultLabel.textColor = .background900
        }
        
        let details = [record.detail1, record.detail2, record.detail3]
        for (index, label) in detailLabels.enumerated() {
            guard index < details.count else { break }
            label.text = details[index]
        }
    }
}
