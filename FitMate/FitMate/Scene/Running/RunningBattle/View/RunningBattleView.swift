//
//  RunningView.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

// JumpRope 협동 모드의 루트 뷰
final class RunningBattleView: BaseView {

    // 실제 메인 UI 뷰
    private let sportsView = BattleSportsView()

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
    func myUpdateProgress(ratio: CGFloat) {
        sportsView.myUpdateProgress(ratio: ratio)
    }
    func mateUpdateProgress(ratio: CGFloat) {
        sportsView.mateUpdateProgress(ratio: ratio)
    }
    func updateGoal(_ text: String) {
        sportsView.updateGoal(text)
    }
}
