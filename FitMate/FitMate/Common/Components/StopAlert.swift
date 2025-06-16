import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class StopAlert: UIView {
    
    // 종류(내가 누름/상대가 누름)
    enum AlertType {
        case myQuitConfirm    // 내가 그만하기 눌렀을 때: 일시정지/그만하기
        case mateQuit        // 상대가 그만하기 눌러서 나도 종료: 돌아가기만
    }
    
    // 콜백(이어할때, 그만둘때,mateQuit되어서 돌아가기)
    var onResume: (() -> Void)?
    var onQuit: (() -> Void)?
    var onBack: (() -> Void)? // mateQuit에서 돌아가기
    
    private let disposeBag = DisposeBag()
    private let container = UIView()
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let resumeButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let buttonStack = UIStackView()
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    init(type: AlertType) {
        super.init(frame: .zero)
        setupUI()
        setAlert(for: type)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        addSubview(dimmedView)
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
        addSubview(container)
        container.backgroundColor = .white
        container.layer.cornerRadius = 5
        container.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(350)
        }
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { $0.size.equalTo(84)}
        titleLabel.font = .boldSystemFont(ofSize: 25)
        titleLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        resumeButton.setTitle("계속하기", for: .normal)
        resumeButton.setTitleColor(.gray, for: .normal)
        resumeButton.backgroundColor = UIColor.systemGray4
        resumeButton.layer.cornerRadius = 5
        resumeButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        
        stopButton.setTitle("그만하기", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .primary300
        stopButton.layer.cornerRadius = 5
        stopButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        
        backButton.setTitle("결과보기", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .primary300
        backButton.layer.cornerRadius = 5
        backButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        backButton.isHidden = true
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.alignment = .center
        buttonStack.addArrangedSubview(resumeButton)
        buttonStack.addArrangedSubview(stopButton)
        buttonStack.isHidden = true
        
        let mainStack = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            messageLabel,
            buttonStack,
            backButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .center
        
        container.addSubview(mainStack)
        mainStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(24) }
        
        resumeButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(124)
        }
        stopButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(124)
        }
        backButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(270)
        }
    }
    
    private func setAlert(for type: AlertType) {
        iconImageView.image = UIImage(named: "stop")
        switch type {
        case .myQuitConfirm:
            titleLabel.text = "정말 그만하시겠어요?"
            messageLabel.text = """
            기록은 안전하게 저장됩니다.
            단, 이 선택은 메이트의 운동도 함께 중단시킵니다.
            메이트도 준비가 되었는지 확인해 주세요.
            """
            buttonStack.isHidden = false
            backButton.isHidden = true
            // Rx 버튼 핸들링
            resumeButton.rx.tap
                .bind { [weak self] in self?.onResume?() }
                .disposed(by: disposeBag)
            stopButton.rx.tap
                .bind { [weak self] in self?.onQuit?() }
                .disposed(by: disposeBag)
        case .mateQuit:
            titleLabel.text = "메이트가 운동을 종료했어요"
            messageLabel.text = """
            메이트가 운동을 그만두었습니다.
            지금까지의 기록은 안전하게
            저장했으니 안심하세요!
            """
            buttonStack.isHidden = true
            backButton.isHidden = false
            backButton.rx.tap
                .bind { [weak self] in self?.onBack?() }
                .disposed(by: disposeBag)
        }
    }
}
