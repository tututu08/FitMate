
import UIKit
import SnapKit

//커스텀 스위치 뷰(디자이너님의 디자인을 완성시키기 위해 제작
final class CustomSwitchView: UIControl {
    
    // 현재 스위치 상태
    private(set) var isOn: Bool = false
    // 스위치 배경 뷰 (온오프에 따라 색상 변경)
    private let backgroundView = UIView()
    // 스위치 손잡이?(동그란거) 뷰
    private let thumbView = UIView()

    //스위치 값이 변경될 때 외부로 전달하기 위한 클로저
    var valueChanged: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI() //UI구성
        setupGesture() //터치 제스쳐 등록
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //스위치 UI 구성
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
    
    // 탭 제스쳐로 스위치 전환 기능 연결
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSwitch))
        addGestureRecognizer(tap)
    }
    
    // 탭할 경우 스위치 상태를 토글
    @objc private func toggleSwitch() {
        isOn.toggle()
        updateAppearance(animated: true)
        valueChanged?(isOn) // 클로저 콜백 호출
        sendActions(for: .valueChanged) //UI컨트롤 이벤트 전파시킴
    }
    
    // 외부에서 스위치 상태 설정
    func setOn(_ isOn: Bool, animated: Bool) {
        self.isOn = isOn
        updateAppearance(animated: animated)
    }
    
    // 온오프에 따른 UI 업데이트
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
