import UIKit
import SnapKit

// 협동 스포츠(여기선 줄넘기 협력 모드) 메인 뷰
class PlankCoopView: BaseView {
    
    var alertView: PauseAlertView?
    var quitAlertView: StopAlertView?
    
    // "협력 모드" 라벨(모드 이름 표시)
    private let modeLabel: UILabel = {
        let label = UILabel()
        label.text = "협력 모드"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 22)
        return label
    }()
    
    // 목표 아이콘(이미지로 보여주기)
    private let goalImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "goalImage") // 목표 아이콘
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 목표값(라벨로 중앙에 노출)
    private let goalLabel: UILabel = {
        let label = UILabel()
        label.text = "종목 목표치" // 예: "목표 100회"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    // "나" 라벨
    private let myLabel: UILabel = {
        let label = UILabel()
        label.text = "나"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()
    
    // "메이트" 라벨(같이 하는 사람)
    private let mateLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()
    
    // 내 기록 라벨(점프 횟수 등)
    private let myRecordLabel: UILabel = {
        let label = UILabel()
        label.text = "나의기록"
        label.textColor = .gray
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    // 메이트 기록 라벨
    private let mateRecordLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트기록"
        label.textColor = .gray
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    // 내/메이트 라벨+기록을 수평으로 묶고, 전체를 수직으로 묶는 스택
    private lazy var recordStackView: UIStackView = {
        // "나" 스택 (나 + 나의 기록)
        let myStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [myLabel,myRecordLabel])
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.alignment = .center
            return stackView
        }()
        // "메이트" 스택 (메이트 + 메이트 기록)
        let mateStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [mateLabel,mateRecordLabel])
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.alignment = .center
            return stackView
        }()
        // 전체 묶음(수직 정렬)
        let mergeStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [myStackView,mateStackView])
            stackView.axis = .vertical
            stackView.spacing = 15
            stackView.alignment = .leading
            return stackView
        }()
        return mergeStackView
    }()
    
    // 진행률 바(배경)
    private let progressBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemPurple.cgColor
        return view
    }()
    
    // 진행률 바(채워지는 부분)
    private let progressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()
    
    // foregroundView width 제약 저장용(진행률 애니메이션)
    private var progressWidthConstraint: Constraint?
    
    // 가운데 로고 이미지
    private let coopImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "plankBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let stateLabel: UILabel = {
        let label = UILabel()
        label.text = "내 차례"
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = UIColor(red: 206/255, green: 255/255, blue: 67/255, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    // 중앙 타이머 라벨
    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "30"
        label.font = .boldSystemFont(ofSize: 50)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let myCharacterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kaepy")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let mateCharacterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "morano")
        imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 일시정지 버튼
    let pauseButton: UIButton = {
        let Button = UIButton()
        Button.setImage(UIImage(named: "pause"), for: .normal)
        return Button
    }()
    
    // 종료 버튼
    let stopButton: UIButton = {
        let Button = UIButton()
        Button.setImage(UIImage(named: "quit"), for: .normal)
        return Button
    }()
    
    // UI 구성 요소 추가
    override func configureUI() {
        self.backgroundColor = .black
        goalImage.addSubview(goalLabel) // 목표 라벨을 이미지 위에 올림(중앙 표시)
        progressBackgroundView.addSubview(progressForegroundView) // 진행률 바 layering
        coopImage.addSubview(stateLabel)
        coopImage.addSubview(timerLabel)
        coopImage.addSubview(myCharacterImage)
        coopImage.addSubview(mateCharacterImage)
        
        [ modeLabel,
          goalImage,
          recordStackView,
          progressBackgroundView,
          coopImage,
          pauseButton,
          stopButton
        ].forEach{self.addSubview($0)}
    }
    
    // SnapKit으로 레이아웃 제약 설정
    override func setLayoutUI() {
        modeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.centerX.equalToSuperview()
        }
        goalImage.snp.makeConstraints {
            $0.top.equalTo(modeLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(350)
            $0.height.equalTo(55)
        }
        goalLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        recordStackView.snp.makeConstraints{
            $0.top.equalTo(goalImage.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(25)
        }
        progressBackgroundView.snp.makeConstraints {
            $0.top.equalTo(recordStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
        progressForegroundView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(6)
            progressWidthConstraint = $0.width.equalTo(0).constraint // 채워지는 바 width 제약
        }
        coopImage.snp.makeConstraints {
            $0.bottom.equalTo(stopButton.snp.top).inset(-50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(340)
            $0.height.equalTo(310)
        }
        stateLabel.snp.makeConstraints {
            $0.top.equalTo(coopImage).offset(14)
            $0.centerX.equalTo(coopImage)
        }
        
        timerLabel.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(10)
            $0.centerX.equalTo(coopImage)
        }
        myCharacterImage.snp.makeConstraints{
            $0.leading.equalTo(coopImage.snp.leading).inset(10)
            $0.bottom.equalTo(coopImage.snp.bottom).inset(18)
            $0.height.equalTo(140)
            $0.width.equalTo(120)
        }
        mateCharacterImage.snp.makeConstraints{
            $0.trailing.equalTo(coopImage.snp.trailing).inset(10)
            $0.bottom.equalTo(coopImage.snp.bottom).inset(18)
            $0.height.equalTo(140)
            $0.width.equalTo(120)
        }
        
        pauseButton.snp.makeConstraints{
            $0.bottom.equalToSuperview().inset(60)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(60)
        }
        stopButton.snp.makeConstraints{
            $0.bottom.equalToSuperview().inset(60)
            $0.leading.equalTo(pauseButton.snp.trailing).offset(12)
            $0.height.equalTo(60)
            $0.width.equalTo(260)
        }
    }
    // 내 기록 라벨 갱신
    func updateMyRecord(_ text: String) {
        myRecordLabel.text = text
    }
    // 메이트 기록 라벨 갱신
    func updateMateRecord(_ text: String) {
        mateRecordLabel.text = text
    }
    // 목표치 라벨 갱신
    func updateGoal(_ text: String) {
        goalLabel.text = text
    }
    func updateMyCharacter(_ name: String) {
        myCharacterImage.image = UIImage(named: name)
    }
    func updateMateCharacter(_ name: String) {
        mateCharacterImage.image = UIImage(named: name)
    }
    // 진행률 바 갱신(0~1 비율)
    func updateProgress(ratio: CGFloat) {
        layoutIfNeeded()
        let width = progressBackgroundView.bounds.width - 12 // inset 보정
        progressWidthConstraint?.update(offset: width * min(1, max(0, ratio)))
        layoutIfNeeded()
    }
    func updatePhase(_ phase: PlankPhase, timer: Int) {
        switch phase {
        case .ready:
            stateLabel.text = "준비하세요"
            stateLabel.textColor = .white
            timerLabel.textColor = .orange
        case .myTurn:
            stateLabel.text = "내 차례"
            stateLabel.textColor = UIColor(red: 206/255, green: 255/255, blue: 67/255, alpha: 1)
            timerLabel.textColor = .systemGreen
        case .mateTurn:
            if timer <= 5 {
                stateLabel.text = "준비하세요 곧 내 차례 입니다!"
                stateLabel.textColor = .orange
            } else {
                stateLabel.text = "쉬는 시간"
                stateLabel.textColor = .systemPurple
            }
            timerLabel.textColor = .systemPurple
        default :
            break
        }
        
        
        func updateTurn(_ isMyTurn: Bool) {
            // isMyTurn에 따라 프로그레스바 색이나 캐릭터 강조 등
        }
        
    }
    // PlankCoopView.swift (또는 별도 View 파일)

    func showAlert(
        type: PauseAlertView.AlertType,
        onResume: (() -> Void)? = nil,
        onQuit: (() -> Void)? = nil
    ) {
        // 이미 알럿이 떠 있으면 중복 방지
        if alertView != nil { return }
        
        // PlankPauseAlertView는 커스텀 UIView
        let alert = PauseAlertView(type: type)
        
        // 버튼 콜백(내가 누를 수 있는 경우에만)
        alert.onResume = { [weak self] in
            onResume?()
            self?.hideAlert()
        }
        
        // addSubview로 화면 중앙에 띄우기 (SnapKit or AutoLayout)
        self.addSubview(alert)
        alert.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(220)
        }
        self.alertView = alert
    }


    func hideAlert() {
        alertView?.removeFromSuperview()
        alertView = nil
    }
    // PlankCoopView 확장
    func showQuitAlert(
        type: StopAlertView.AlertType,
        onResume: (() -> Void)? = nil,
        onQuit: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        if quitAlertView != nil { return }
        let alert = StopAlertView(type: type)
        alert.onResume = { [weak self] in onResume?(); self?.hideQuitAlert() }
        alert.onQuit = { [weak self] in onQuit?(); self?.hideQuitAlert() }
        alert.onBack = { [weak self] in onBack?(); self?.hideQuitAlert() }
        self.addSubview(alert)
        alert.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(320)
        }
        self.quitAlertView = alert
    }

    func hideQuitAlert() {
        quitAlertView?.removeFromSuperview()
        quitAlertView = nil
    }

}
extension PlankCoopView {
    /// 일시정지 버튼 활성/비활성 & 이미지 교체
    func setPauseButtonEnabled(_ enabled: Bool) {
        pauseButton.isEnabled = enabled
        let imageName = enabled ? "pause" : "setting"
        pauseButton.setImage(UIImage(named: imageName), for: .normal)
    }
}
