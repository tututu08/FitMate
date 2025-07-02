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
        updateMateAvatarImage()
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
                cell.configure(with: record, index: index)
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
    
    private func updateMateAvatarImage() {
        FirestoreService.shared.loadSelectedAvatar(uid: mateUid)
            .subscribe(onSuccess: { [weak self] avatarType in
                guard let self,
                      let avatarType,
                      let avatar = AvatarType.allCases.first(where: { $0 == avatarType }),
                      let image = UIImage(named: avatar.imageName),
                      let cgImage = image.cgImage else { return }

                let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                self.rootView.profileImageView.image = fixed
            })
            .disposed(by: disposeBag)
    }
}
