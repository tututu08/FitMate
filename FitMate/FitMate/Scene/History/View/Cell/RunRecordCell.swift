
import UIKit
import SnapKit

final class RunRecordCell: UICollectionViewCell {
    static let identifier = "RunRecordCell"
    
    // 기록 저장을 위한 배열
    private var detailLabels: [UILabel] = []
    
    // 캐릭터 이미지
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "run")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //달리기
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "달리기"
        label.font = UIFont(name: "Pretendard-Medium", size: 20)
        label.textColor = .black
        return label
    }()
    
    // 운동 결과
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "0000.00.00"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = .gray
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "대결-패배"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
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
    
    // 셀 전체 레이아웃 구성
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
        valueLabel.font = UIFont(name: "Pretendard-SemiBold", size: 22)
        valueLabel.textColor = .black
        valueLabel.textAlignment = .left
        valueLabel.snp.makeConstraints { $0.height.equalTo(31) }
        
        detailLabels.append(valueLabel)
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
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
    
    // 운동기록을 전달받아 셀 업데이트
    func configure(with record: ExerciseRecord) {
        dateLabel.text = record.dateOnly
        resultLabel.text = record.result.rawValue
        
        // 결과에 따가 색상 설정
        switch record.result {
        case .teamSuccess, .teamFail:
            resultLabel.backgroundColor = UIColor(named: "Primary500")
            resultLabel.textColor = .white
        case .versusWin, .versusLose:
            resultLabel.backgroundColor = UIColor(named: "Secondary400")
            resultLabel.textColor = .black
        }
        
        let details = [record.detail1, record.detail2, record.detail3]
        for (index, label) in detailLabels.enumerated() {
            guard index < details.count else { break }
            label.text = details[index]
        }
    }
}
