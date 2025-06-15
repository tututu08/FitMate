import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class StopAlertView: UIView {
    // 종류(내가 누름/상대가 누름)
    enum AlertType {
        case myQuitConfirm    // 내가 그만하기 눌렀을 때: 일시정지/그만하기
        case mateQuit        // 상대가 그만하기 눌러서 나도 종료: 돌아가기만
    }
    
    // 콜백
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
    
    init(type: AlertType) {
        super.init(frame: .zero)
        setupUI()
        configure(for: type)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(container)
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        container.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
        }
        
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        resumeButton.setTitle("일시정지", for: .normal)
        resumeButton.setTitleColor(.systemPurple, for: .normal)
        resumeButton.backgroundColor = UIColor.systemGray6
        resumeButton.layer.cornerRadius = 12
        resumeButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        
        stopButton.setTitle("그만하기", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .systemPurple
        stopButton.layer.cornerRadius = 12
        stopButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        
        backButton.setTitle("돌아가기", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .systemPurple
        backButton.layer.cornerRadius = 12
        backButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        
        // 기본적으로 모든 버튼 hidden, configure에서 제어
        [resumeButton, stopButton, backButton].forEach { $0.isHidden = true }
        
        // 스택뷰
        let stack = UIStackView(arrangedSubviews: [
            iconImageView, titleLabel, messageLabel, resumeButton, stopButton, backButton
        ])
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .center
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(24) }
        iconImageView.snp.makeConstraints { $0.height.width.equalTo(48) }
        [resumeButton, stopButton, backButton].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(48); $0.width.equalTo(200) }
        }
    }
    
    private func configure(for type: AlertType) {
        iconImageView.image = UIImage(named: "stop")
        switch type {
        case .myQuitConfirm:
            titleLabel.text = "정말 그만하시겠어요?"
            messageLabel.text = """
            기록은 안전하게 저장됩니다.
            단, 이 선택은 상대방의 운동도 함께 중단시킵니다.
            상대방도 준비가 되었는지 확인해 주세요.
            """
            resumeButton.isHidden = false
            stopButton.isHidden = false
            backButton.isHidden = true
            // Rx 버튼 핸들링
            resumeButton.rx.tap
                .bind { [weak self] in self?.onResume?() }
                .disposed(by: disposeBag)
            stopButton.rx.tap
                .bind { [weak self] in self?.onQuit?() }
                .disposed(by: disposeBag)
        case .mateQuit:
            titleLabel.text = "상대가 운동을 종료했어요"
            messageLabel.text = """
            상대가 나갔습니다.
            메인화면으로 돌아가겠습니다.
            현재까지 기록은 안전하게 저장됩니다.
            """
            resumeButton.isHidden = true
            stopButton.isHidden = true
            backButton.isHidden = false
            backButton.rx.tap
                .bind { [weak self] in self?.onBack?() }
                .disposed(by: disposeBag)
        }
    }
}
