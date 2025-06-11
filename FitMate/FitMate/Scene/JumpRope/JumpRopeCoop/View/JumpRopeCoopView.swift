import UIKit
import SnapKit

// JumpRope 협동 모드의 루트 뷰
final class JumpRopeCoopView: UIView {

    // 실제 메인 UI 뷰
    private let sportsView = CooperationSportsView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // sportsView를 서브뷰로 추가
    private func configureUI() {
        addSubview(sportsView)
    }

    // sportsView를 전체 영역에 맞게 제약
    private func setupLayout() {
        sportsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // 아래 함수들은 뷰모델/컨트롤러에서 기록,진행률,목표치를 갱신할 때 호출
    func updateMyRecord(_ text: String) {
        sportsView.updateMyRecord(text)
    }
    func updateMateRecord(_ text: String) {
        sportsView.updateMateRecord(text)
    }
    func updateProgress(ratio: CGFloat) {
        sportsView.updateProgress(ratio: ratio)
    }
    func updateGoal(_ text: String) {
        sportsView.updateGoal(text)
    }
}
