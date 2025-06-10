//
//  JumpRopeCoopView.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

/// Root view for the jump rope cooperation scene.
/// It embeds ``CooperationSportsView`` and exposes
/// helper methods for updating its UI components.
final class JumpRopeCoopView: UIView {

    private let sportsView = CooperationSportsView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
        setupLayout()
    }

    private func configureUI() {
        addSubview(sportsView)
    }

    private func setupLayout() {
        sportsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Proxy helpers

    func updateMyRecord(_ text: String) {
        sportsView.updateMyRecord(text)
    }

    func updateMateRecord(_ text: String) {
        sportsView.updateMateRecord(text)
    }

    func updateProgress(ratio: CGFloat) {
        sportsView.updateProgress(ratio: ratio)
    }

    /// 목표치 텍스트를 갱신합니다.
    func updateGoal(_ text: String) {
        sportsView.updateGoal(text)
    }
}
