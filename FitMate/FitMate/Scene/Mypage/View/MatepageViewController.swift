import UIKit
import RxSwift
import RxCocoa

// 메이트의 마이페이지를 보여주는 뷰컨
final class MatepageViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    private let rootView: MypageView
    private let viewModel: MypageViewModel
    private let disposeBag = DisposeBag()
    
    private let mateUid: String
    
    // 메이트 UID를 받아서 초기화 시키고 UID기반으로 유저의 정보 표시시킴
    init(mateUid: String) {
        self.mateUid = mateUid
        self.viewModel = MypageViewModel(uid: mateUid)
        self.rootView = MypageView(
            showSettingButton: false, //설정버튼 비노출
            titleText: "메이트페이지", //타이틀 설정
            showBackButton: true //뒤로가기버튼 노출
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
        
        //운동 기록뷰 델리게이트 설정
        rootView.recordCollectionView.delegate = self
        bindViewModel()
        
        //운동 기록 셀 등록
        rootView.recordCollectionView.register(
            WorkRecordCell.self,
            forCellWithReuseIdentifier: WorkRecordCell.identifier
        )
        
        setupBackButtonAction()
        updateMateAvatarImage()
    }
    
    // 뷰모델 바인딩: 닉네임과 누적기록을 연결
    private func bindViewModel() {
        let output = viewModel.transform()
        
        // 닉네임 바인딩
        output.nickname
            .drive(rootView.nicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        //누적기록 리스트 바인딩
        output.records
            .drive(rootView.recordCollectionView.rx.items(
                cellIdentifier: WorkRecordCell.identifier,
                cellType: WorkRecordCell.self
            )) { index, record, cell in
                cell.configure(with: record, index: index)
            }
            .disposed(by: disposeBag)
    }
    
    // 뒤로가기 버튼 탭 시 이전화면으로 이동
    private func setupBackButtonAction() {
        rootView.backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // 운동 기록 셀 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 120)
    }
    
    // firestore에서 메이트의 아바타 이미지 불러와서 적용
    private func updateMateAvatarImage() {
        FirestoreService.shared.loadSelectedAvatar(uid: mateUid)
            .subscribe(onSuccess: { [weak self] avatarType in
                guard let self,
                      let avatarType,
                      let avatar = AvatarType.allCases.first(where: { $0 == avatarType }),
                      let image = UIImage(named: avatar.imageName),
                      let cgImage = image.cgImage else { return }
                
                // 이미지가 반대로 나올 경우를 대비해 orientatino 고정시킴
                let fixed = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
                self.rootView.profileImageView.image = fixed
            })
            .disposed(by: disposeBag)
    }
}
