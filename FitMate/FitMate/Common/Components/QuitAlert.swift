import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class QuitAlert: UIView {
    
    // 종류(내가 누름/상대가 누름)
    enum AlertType {
        case myQuitConfirm    // 내가 그만하기 눌렀을 때: 일시정지/그만하기
        case mateQuit        // 상대가 그만하기 눌러서 나도 종료: 돌아가기만
        case cancelLocation
//        case cancelLocationByMe
//        case cancelLocationByMate
        
    }
    
    // 콜백(이어할때, 그만둘때,mateQuit되어서 돌아가기)
    var onResume: (() -> Void)?
    var onQuit: (() -> Void)?
    var onBack: (() -> Void)? // mateQuit에서 돌아가기
    var onHome: (() -> Void)? // 위치 거절해서 홈으로 돌아가기
    
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
    
    func setMessage(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6  // 원하는 줄간격으로 조절 (예: 6)
        paragraphStyle.alignment = .center //
        let attributedString = NSAttributedString(string: text, attributes: [
            .font: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.background400,
            .paragraphStyle: paragraphStyle
        ])
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.attributedText = attributedString
       }
    
    private func setupUI() {
        addSubview(dimmedView)
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
        addSubview(container)
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.snp.makeConstraints {
            $0.center.equalToSuperview()
//            $0.width.equalTo(320)
            $0.width.equalTo(326)
            //$0.height.equalTo(350)
        }
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { $0.size.equalTo(84)}
//        iconImageView.isHidden = true
        titleLabel.font = UIFont(name: "Pretendard-Regular", size: 25)
        titleLabel.textColor = .background900
        titleLabel.textAlignment = .center
//        messageLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
//        messageLabel.textColor = .gray
//        messageLabel.textAlignment = .center
//        messageLabel.numberOfLines = 0
        
        resumeButton.setTitle("계속하기", for: .normal)
        resumeButton.setTitleColor(.gray, for: .normal)
        resumeButton.backgroundColor = .background50
        resumeButton.layer.cornerRadius = 5
        resumeButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        
        stopButton.setTitle("그만하기", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .primary500
        stopButton.layer.cornerRadius = 4
        stopButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        
        backButton.setTitle("돌아가기", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .primary300
        backButton.layer.cornerRadius = 5
        backButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        backButton.isHidden = true
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(resumeButton)
        buttonStack.addArrangedSubview(stopButton)
        buttonStack.isHidden = true
        
        let mainStack = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            messageLabel,
            //buttonStack,
            backButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .center
        
        container.addSubview(mainStack)
        container.addSubview(buttonStack)
        container.addSubview(backButton)
        
        mainStack.snp.makeConstraints {
//            $0.edges.equalToSuperview()
            $0.top.equalToSuperview().offset(32)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(mainStack.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        resumeButton.snp.makeConstraints {
            $0.height.equalTo(48)
            //$0.width.equalTo(124)
        }
        stopButton.snp.makeConstraints {
            $0.height.equalTo(48)
            //$0.width.equalTo(124)
        }
        backButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(270)
//            $0.bottom.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(container.snp.bottom).inset(20) //
        }
    }
    
    private func setAlert(for type: AlertType) {
        iconImageView.image = UIImage(named: "stop")
        switch type {
        case .myQuitConfirm:
            titleLabel.text = "정말 그만하시겠어요?"
            setMessage("""
            ⚠️ 당신의 메이트도 함께 중단됩니다.
            기록은 안전하게 저장되지만
            당신의 열쩡을 믿어볼게요.
            """)
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
            titleLabel.text = "나약한 메이트"
            setMessage("""
            당신의 메이트, 꽤나 나약하네요?🤔
            기록은 걱정마요~ 센스있는 제가 
            안전하게 저장해두었답니다!
            """)
//            iconImageView.isHidden = false
            buttonStack.isHidden = true
            backButton.isHidden = false
            backButton.rx.tap
                .bind { [weak self] in self?.onBack?() }
                .disposed(by: disposeBag)
        case .cancelLocation:
            titleLabel.text = "메이트의 행방불명"
            setMessage("""
            이런.. 메이트의 위치를 알 수 없어요🧖🏻
            메이트가 위치 권한 설정 동의 후
            우리 다시 운동해봐요~!
            """)
//            iconImageView.isHidden = false
            buttonStack.isHidden = true
            backButton.isHidden = false
            backButton.rx.tap
                .bind { [weak self] in self?.onHome?() }
                .disposed(by: disposeBag)
//        case .cancelLocationByMe:
//            titleLabel.text = "위치 권한이 필요합니다"
//            setMessage("""
//            위치 권한이 거부되어서 운동이 종료됩니다ㅠㅠ
//            [설정]에서 위치 권한을 허용하신 뒤 
//            다시 시도해 주세요!
//            """)
//            iconImageView.isHidden = false
//            buttonStack.isHidden = true
//            backButton.isHidden = false
//            backButton.rx.tap
//                .bind { [weak self] in self?.onHome?() }
//                .disposed(by: disposeBag)
        }
    }
}
