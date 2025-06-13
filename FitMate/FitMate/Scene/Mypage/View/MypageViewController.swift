//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//


import UIKit
import RxSwift
import RxCocoa

final class MypageViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    private let rootView = MypageView()
    private let viewModel = MypageViewModel()
    private let disposeBag = DisposeBag()

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.recordCollectionView.delegate = self
        bindViewModel()
        rootView.recordCollectionView.register(WorkRecordCell.self, forCellWithReuseIdentifier: WorkRecordCell.identifier)
    }

    private func bindViewModel() {
        let output = viewModel.transform()

        output.nickname
            .drive(rootView.nicknameLabel.rx.text)
            .disposed(by: disposeBag)

        output.records
            .drive(rootView.recordCollectionView.rx.items(cellIdentifier: WorkRecordCell.identifier, cellType: WorkRecordCell.self)) { index, record, cell in
                // 실제 데이터 연결은 추후에 구현
            }
            .disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 120)
    }
}
