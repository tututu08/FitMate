
import UIKit

final class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    // 카테고리 이름을 보여줌
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "Background50") // 선택하지 않았을 경우의 상태 색상
        label.textAlignment = .center
        return label
    }()
    
    // 셀이 선택된 경우의 UI
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected
                ? UIColor(named: "Primary500")
                : .clear
            titleLabel.textColor = isSelected
                ? .white
                : UIColor(named: "Primary100")
            titleLabel.font = isSelected
                ? .boldSystemFont(ofSize: 14)
                : .systemFont(ofSize: 14)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 4
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.masksToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // 외부에서 카테고리 이름을 지정시킴
    func configure(with title: String) {
        titleLabel.text = title
    }
}
