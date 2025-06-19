//
//  WebViewController.swift
//  FitMate
//
//  Created by soophie on 6/18/25.
//

import UIKit
import WebKit
import SnapKit

class WebViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var urlString: String? // 표시할 웹페이지 url
    var urlTitle: String? // 페이지 타이틀 서비스 이용약관 / 개인정보 이용방침
    
    private let closeButton: UIButton = {
       let close = UIButton()
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        return close
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureWeb()
        view.addSubview(closeButton)
        setUpUI()
        loadWebPage()
        setupNavigationBar()
    }
    
    /// 웹뷰 초기 설정
    private func configureWeb() {
        let webContiguration = WKWebViewConfiguration() // 웹 성정 구성 객체
        webView = WKWebView(frame: .zero, configuration: webContiguration)
        webView.uiDelegate = self // 필요 시 사용자 인터랙션 대응
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView) // 루트 뷰를 webView로 설정
        
    }
    // 화면 제약
    private func setUpUI() {
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.size.equalTo(28)
        }
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
    }
    
    // 모달 닫기
    @objc private func closeModal() {
        dismiss(animated: true)
    }

    
    /// 네비게이션 바 타이틀 설정
    private func setupNavigationBar() {
        self.title = urlTitle
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
    }
    
    /// url 문자열을 기반으로 웹페이지 로그
    /// 유효한 url일 경우 WKWebview에 해당 페이지 로드
    private func loadWebPage() {
        /// 외부에서 전달 받은 url이 유효한지 판단하고 url 객체로 반환
        guard let urlString = urlString,
              let url = URL(string: urlString) else { return }
        
        /// urlrequest 생성 후 웹뷰에 로드
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
