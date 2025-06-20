// MypageViewController.swift
import UIKit
import RxSwift
import RxCocoa

final class MypageViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    private let rootView = MypageView(showSettingButton: true, titleText: "마이페이지")
    private let viewModel: MypageViewModel
    private let disposeBag = DisposeBag()
    
    private let uid: String
    
    init(uid: String) {
        self.uid = uid
        self.viewModel = MypageViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.recordCollectionView.delegate = self
        bindViewModel()
        bindActions()
        rootView.recordCollectionView.register(
            WorkRecordCell.self,
            forCellWithReuseIdentifier: WorkRecordCell.identifier
        )
    }

    private func bindViewModel() {
        let output = viewModel.transform()

        output.nickname
            .drive(rootView.nicknameLabel.rx.text)
            .disposed(by: disposeBag)

        output.records
            .drive(rootView.recordCollectionView.rx.items(
                cellIdentifier: WorkRecordCell.identifier,
                cellType: WorkRecordCell.self
            )) { index, record, cell in
                cell.configure(with: record)
            }
            .disposed(by: disposeBag)
    }

    private func bindActions() {
        rootView.settingButton.rx.tap
            .bind { [weak self] in
                let settingVC = SettingViewController()
                settingVC.modalPresentationStyle = .overFullScreen
                self?.present(settingVC, animated: false, completion: nil)
            }
            .disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 120)
    }
}
