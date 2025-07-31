import UIKit
import RxSwift
import RxCocoa

final class MypageViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    //상단바 구성
    let rootView = MypageView(showSettingButton: true, titleText: "마이페이지", showBackButton: false)
    
    // 사용자 식별에 따른 뷰모델 인스턴스
    private let viewModel: MypageViewModel
    private let disposeBag = DisposeBag()
    private let uid: String
    
    //uid 기반 생성자
    init(uid: String) {
        self.uid = uid
        self.viewModel = MypageViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView //루트 뷰 설정
    }
    
    // 네비게이션 바 숨김처리
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 프로필 이미지 업뎃
        updateSelectedAvatarImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 기록 컬렉션 뷰 부분 delegate 설정
        rootView.recordCollectionView.delegate = self
        // 뷰모델 바인딩 및 버튼 액션 바인딩
        bindViewModel()
        bindActions()
        //셀등록
        rootView.recordCollectionView.register(
            WorkRecordCell.self,
            forCellWithReuseIdentifier: WorkRecordCell.identifier
        )
    }
    
    // 뷰모델의 아웃풋을 위한 view와 바인딩
    private func bindViewModel() {
        let output = viewModel.transform()
        
        //닉네임바인딩
        output.nickname
            .drive(rootView.nicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        //기록 바인딩
        output.records
            .drive(rootView.recordCollectionView.rx.items(
                cellIdentifier: WorkRecordCell.identifier,
                cellType: WorkRecordCell.self
            )) { index, record, cell in
                cell.configure(with: record, index: index)
            }
            .disposed(by: disposeBag)
    }
    
    //설정버튼 탭 바인딩 (설정 화면 모달 표시)
    private func bindActions() {
        rootView.settingButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                let settingVC = SettingViewController(uid: self.uid)
                settingVC.modalPresentationStyle = .overFullScreen
                self.present(settingVC, animated: false, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 120)
    }
    
    //Rx를 사용해 선택된 아바타를 업데이트
    private func updateSelectedAvatarImage() {
        AvatarManager.shared.selectedAvatarRelay
            .compactMap { $0 } // AvatarType
            .observe(on: MainScheduler.instance)
            .bind { [weak self] avatar in
                guard let self else { return }
                
                let imageName = avatar.imageName
                if let image = UIImage(named: imageName),
                   let cgImage = image.cgImage {
                    let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                    self.rootView.profileImageView.image = fixed
                }
            }
            .disposed(by: disposeBag)
    }
}
