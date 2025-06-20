import UIKit
import RxSwift
import RxCocoa

final class MatepageViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    private let rootView: MypageView
    private let viewModel: MypageViewModel
    private let disposeBag = DisposeBag()

    private let mateUid: String

    init(mateUid: String) {
        self.mateUid = mateUid
        self.viewModel = MypageViewModel(uid: mateUid)
        self.rootView = MypageView(
            showSettingButton: false,
            titleText: "메이트페이지",
            showBackButton: true
        )
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

        rootView.recordCollectionView.register(
            WorkRecordCell.self,
            forCellWithReuseIdentifier: WorkRecordCell.identifier
        )

        setupBackButtonAction()
    }

    private func bindViewModel() {
        let output = viewModel.transform()

        output.nickname
            .drive(rootView.nicknameLabel.rx.text)
            .disposed(by: disposeBag)

        output.records
            .drive(rootView.recordCollectionView.rx.items(
                cellIdentifier: WorkRecordCell.identifier,
                cellType: WorkRecordCell.self)
            ) { index, record, cell in
                cell.configure(with: record)
            }
            .disposed(by: disposeBag)
    }

    private func setupBackButtonAction() {
        rootView.backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 120)
    }
}
