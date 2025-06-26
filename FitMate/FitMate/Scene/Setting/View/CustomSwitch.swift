
import UIKit
import SnapKit

final class CustomSwitchView: UIControl {
    
    private(set) var isOn: Bool = false
    private let backgroundView = UIView()
    private let thumbView = UIView()

    var valueChanged: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(backgroundView)
        addSubview(thumbView)
        
        backgroundView.layer.cornerRadius = 13
        backgroundView.backgroundColor = UIColor(named: "Background50")
        
        thumbView.layer.cornerRadius = 11
        thumbView.backgroundColor = UIColor(named: "Primary500")
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(26)
            $0.width.equalTo(44)
        }
        
        thumbView.snp.makeConstraints {
            $0.width.height.equalTo(22)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(2)
        }
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSwitch))
        addGestureRecognizer(tap)
    }
    
    @objc private func toggleSwitch() {
        isOn.toggle()
        updateAppearance(animated: true)
        valueChanged?(isOn)
        sendActions(for: .valueChanged)
    }
    
    func setOn(_ isOn: Bool, animated: Bool) {
        self.isOn = isOn
        updateAppearance(animated: animated)
    }
    
    private func updateAppearance(animated: Bool) {
        backgroundView.backgroundColor = isOn ? UIColor(named: "Primary100") : UIColor(named: "Background50")
        
        thumbView.snp.remakeConstraints {
            $0.width.height.equalTo(22)
            $0.centerY.equalToSuperview()
            if isOn {
                $0.trailing.equalToSuperview().inset(2)
            } else {
                $0.leading.equalToSuperview().offset(2)
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
}
