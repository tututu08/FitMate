import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PauseAlert: UIView {

    // 어떤 타입의 일시정지 알럿인지 구분
    enum AlertType {
        case myPause      // 내가 일시정지
        case matePause    // 상대가 일시정지
    }

    // 콜백 (이어하기)
    var onResume: (() -> Void)?

    // 내부 타이머 관련
    private let disposeBag = DisposeBag()
    private var timerDisposable: Disposable?

    // UI 요소
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isUserInteractionEnabled = true
        return view
    }()
    private let alertContainer = UIView()

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let timerLabel = UILabel()
    private let resumeButton = UIButton()
    
    init(type: AlertType) {
        super.init(frame: .zero)
        setupUI()
        setAlert(type: type)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        // 1. 전체 dimmedView
        addSubview(dimmedView)
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 2. 알럿 컨테이너
        addSubview(alertContainer)
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 5
        alertContainer.clipsToBounds = true
        alertContainer.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(340) // 높이 고정 시 너무 길면 .greaterThanOrEqualTo로
        }

        // 3. 각 요소 스타일 세팅
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "pause")
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        messageLabel.textColor = .darkGray

        timerLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timerLabel.textColor = .systemPurple
        timerLabel.textAlignment = .center

        resumeButton.setTitle("계속하기", for: .normal)
        resumeButton.setTitleColor(.white, for: .normal)
        resumeButton.backgroundColor = .primary500
        resumeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        resumeButton.layer.cornerRadius = 5

        // 4. StackView 배치 (spacing 맞추기)
        let stack = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            messageLabel,
            timerLabel,
            resumeButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center

        alertContainer.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(20) }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(84) // 원하는 크기로!
        }
        resumeButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(alertContainer).multipliedBy(0.85)
        }
        timerLabel.snp.makeConstraints {
            $0.width.equalTo(resumeButton)
        }

    }
    
    private func setAlert(type: AlertType) {
//        timerLabel.isHidden = false
        switch type {
        case .myPause:
            titleLabel.text = "운동이 잠시 멈췄어요"
            messageLabel.text = "운동이 일시정지 되었습니다.\n준비되면 이어서 계속해 보세요!"
            resumeButton.isHidden = false
            resumeButton.setTitle("계속하기", for: .normal)
            resumeButton.isEnabled = true
            resumeButton.backgroundColor = .primary300
            resumeButton.setTitleColor(.white, for: .normal)
            startCountdown(from: 10) // 3분(=180), 테스트용 10
        case .matePause:
            titleLabel.text = "메이트가 일시정지를 했습니다."
            messageLabel.text = "메이트가 돌아올 때까지 잠시만 기다려주세요.\n대기 시간이 지나면 자동으로 재개됩니다."
            resumeButton.isHidden = false
            resumeButton.setTitle("잠시만 기다려주세요", for: .normal)
            resumeButton.isEnabled = false
            resumeButton.backgroundColor = UIColor.systemGray4
            resumeButton.setTitleColor(.darkGray, for: .disabled)
            startCountdown(from: 10)
        }
        // Rx로 버튼 클릭 이벤트 처리
        resumeButton.rx.tap
            .bind { [weak self] in self?.onResume?() }
            .disposed(by: disposeBag)
    }
        private func startCountdown(from seconds: Int) {
        var remain = seconds
        timerLabel.text = "남은 시간: \(formatTime(remain))"
        timerDisposable?.dispose()
        timerDisposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(until: { _ in remain <= 0 })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                remain -= 1
                self.timerLabel.text = "남은 시간: \(self.formatTime(remain))"
                if remain <= 0 {
                    self.onResume?()
                    self.removeFromSuperview()
                }
            })
        timerDisposable?.disposed(by: disposeBag)
    }
    // 2:59 처럼 포맷
    private func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%d:%02d", min, sec)
    }
    deinit { timerDisposable?.dispose() }
}
