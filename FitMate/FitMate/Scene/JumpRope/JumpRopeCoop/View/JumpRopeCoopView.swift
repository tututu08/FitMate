import UIKit
import SnapKit

// JumpRope 협동 모드의 루트 뷰
final class JumpRopeCoopView: BaseView {

    // 실제 메인 UI 뷰
    private let sportsView = CooperationSportsView()
    var quitAlertView: QuitAlert?
    var stopButton: UIButton {
        return sportsView.stopButton
       }
    // sportsView를 서브뷰로 추가
    override func configureUI() {
        addSubview(sportsView)
    }

    // sportsView를 전체 영역에 맞게 제약
    override func setLayoutUI() {
        sportsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func showQuitAlert(
        type: QuitAlert.AlertType,
        onResume: (() -> Void)? = nil,
        onQuit: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        if quitAlertView != nil { return }
        let alert = QuitAlert(type: type)
        alert.onResume = { [weak self] in onResume?(); self?.hideQuitAlert() }
        alert.onQuit = { [weak self] in onQuit?(); self?.hideQuitAlert() }
        alert.onBack = { [weak self] in onBack?(); self?.hideQuitAlert() }
        self.addSubview(alert)
        alert.snp.makeConstraints {
                $0.edges.equalToSuperview()
        }
        self.quitAlertView = alert
    }

    func hideQuitAlert() {
        quitAlertView?.removeFromSuperview()
        quitAlertView = nil
    }
    
    // 아래 함수들은 뷰모델/컨트롤러에서 기록,진행률,목표치를 갱신할 때 호출
    func updateMyRecord(_ text: String) {
        sportsView.updateMyRecord(text)
    }
    func updateMateRecord(_ text: String) {
        sportsView.updateMateRecord(text)
    }
    func updateMyCharacter(_ name: String) {
        sportsView.updateMyCharacter(name)
    }
    func updateMateCharacter(_ name: String) {
        sportsView.updateMateCharacter(name)
    }
    func updateProgress(ratio: CGFloat) {
        sportsView.updateProgress(ratio: ratio)
    }
    func updateGoal(_ text: String) {
        sportsView.updateGoal(text)
    }
}
