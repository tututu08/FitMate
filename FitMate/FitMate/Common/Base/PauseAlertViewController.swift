import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PauseAlertView: UIView {

    // 어떤 타입의 일시정지 알럿인지 구분
    enum AlertType {
        case myPause      // 내가 일시정지
        case matePause    // 상대가 일시정지
    }

    // 콜백 (이어하기, 그만두기 등)
    var onResume: (() -> Void)?

    // 내부 타이머 관련
    private let disposeBag = DisposeBag()
    private var timerDisposable: Disposable?

    // UI 요소
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
        // dimmedView로 전체 덮기
        addSubview(dimmedView)
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
        // 알럿 컨테이너
        addSubview(alertContainer)
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 20
        alertContainer.clipsToBounds = true
        alertContainer.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
        }
        // 내부 컴포넌트 기본 셋팅
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        timerLabel.font = .boldSystemFont(ofSize: 16)
        timerLabel.textColor = .systemPurple
        timerLabel.textAlignment = .center
        resumeButton.setTitle("계속하기", for: .normal)
        resumeButton.setTitleColor(.white, for: .normal)
        resumeButton.backgroundColor = .systemPurple
        resumeButton.layer.cornerRadius = 12
        
        // 스택뷰로 정렬
        let stack = UIStackView(arrangedSubviews: [
            iconImageView, titleLabel, messageLabel, timerLabel, resumeButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        alertContainer.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(24) }
        iconImageView.snp.makeConstraints { $0.height.width.equalTo(48) }
        resumeButton.snp.makeConstraints { $0.height.equalTo(48); $0.width.equalTo(200) }
        timerLabel.snp.makeConstraints { $0.width.equalTo(200) }
    }
    
    private func setAlert(type: AlertType) {
        iconImageView.image = UIImage(named: "pause")
        timerLabel.isHidden = false
        
        switch type {
        case .myPause:
            titleLabel.text = "운동이 잠시 멈췄어요"
            messageLabel.text = "운동이 일시정지 되었습니다.\n준비되면 이어서 계속해 보세요!"
            resumeButton.isHidden = false
            startCountdown(from: 180) // 3분
        case .matePause:
            titleLabel.text = "상대가 운동을 멈췄어요"
            messageLabel.text = "상대방이 일시정지 했습니다.\n잠시 기다려주세요!"
            resumeButton.isHidden = true
            startCountdown(from: 180) // 3분
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
