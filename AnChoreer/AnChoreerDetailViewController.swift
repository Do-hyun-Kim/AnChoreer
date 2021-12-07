//
//  AnChoreerDetailViewController.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/03.
//

import UIKit
import WebKit

class AnChoreerDetailViewController: UIViewController,StateAnimateViewDelegate {
        
    //MARK: - Properties
    
    
    @IBOutlet weak var detailMovieImageView: UIImageView!
    @IBOutlet weak var detailMovieDirectorTitleLabel: UILabel!
    @IBOutlet weak var detailMovieActorTitleLabel: UILabel!
    @IBOutlet weak var detailMovieUserSuggestButton: UIButton!
    @IBOutlet weak var detailMovieUserRatingLabel: UILabel!
    @IBOutlet weak var detailWebView: WKWebView!
    
    var selectIndex: Int = 0
    var detailFlag: [Bool] = []
    var suggestInfo:SearchModelInfo?
    var detailInfoDictionary:[Int:SearchModelInfo] = [:]
    var detailInfo:[SearchModelInfo] = []
    var detailKeyInfo:[Int] = []
    
    
    //MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        webViewConfigure()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if detailFlag[selectIndex] {
            self.detailMovieUserSuggestButton.setImage(UIImage(named: "starEnable"), for: .normal)
        } else {
            self.detailMovieUserSuggestButton.setImage(UIImage(named: "stardDisable"), for: .normal)
        }
    }
    
    
    //MARK: - Helpers
    
    
    private func configure() {
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "navigationImage"), for: .normal)
        backbutton.addTarget(self, action: #selector(detailBackButtonDidTap), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        self.navigationController?.navigationBar.tintColor = .black
        let titleString = suggestInfo?.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let detailTitleView = UILabel()
        detailTitleView.text = titleString ?? "값이 비워있습니다"
        detailTitleView.font = UIFont.boldSystemFont(ofSize: 18)
        self.navigationItem.titleView = detailTitleView
        detailMovieUserRatingLabel.text = "평점: \(suggestInfo?.userRating ?? "값이 비워있습니다")"
        detailMovieActorTitleLabel.text = "출연: \(suggestInfo?.actor ?? "값이 비워있습니다")"
        detailMovieDirectorTitleLabel.text = "배우: \(suggestInfo?.director ?? "값이 비워있습니다")"
        detailMovieImageView.contentMode = .scaleToFill
        if let bindingImage = suggestInfo?.image {
            guard let urlString = URL(string: bindingImage) else { return }
            
            guard let data = try? Data(contentsOf: urlString), let image = UIImage(data: data) else {
                return
            }
            detailMovieImageView.image = image
        }
        detailMovieUserSuggestButton.addTarget(self, action: #selector(suggestButtonDidTap), for: .touchUpInside)
    }
    
    private func webViewConfigure() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            guard let bindingLink = self.suggestInfo?.link else { return }
            guard let urlString = URL(string: bindingLink) else {
                return
            }
            let requestUrl = URLRequest(url: urlString)
            DispatchQueue.main.async {
                self.detailWebView.load(requestUrl)
            }
        }
    }
    
    
    
    public func pushDetailInfo() {
        DispatchQueue.global().sync { [self] in
            if detailFlag[selectIndex] == false {
                detailInfoDictionary.removeValue(forKey: selectIndex)
                for (_, item) in detailInfoDictionary.enumerated() {
                    detailInfo.append(item.value)
                    detailKeyInfo.append(item.key)
                }
            } else {
                for (_, item) in detailInfoDictionary.enumerated() {
                    detailInfo.append(item.value)
                    detailKeyInfo.append(item.key)
                }
            }
        }
    }
    
    func stateSuggestView(state: Bool, View view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isOpaque = false
        view.tag = 2
        view.layer.cornerRadius = 5
        view.alpha = 0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.frame = CGRect(x: self.view.center.x, y: self.view.frame.height, width: 150, height: 40)
        self.view.addSubview(view)
        view.centerXAnchor
            .constraint(equalTo: self.view.centerXAnchor)
            .isActive = true
        view.widthAnchor
            .constraint(equalToConstant: view.frame.width)
            .isActive = true
        view.heightAnchor
            .constraint(equalToConstant: 40)
            .isActive = true
        view.bottomAnchor
            .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            .isActive = true
        let detailTitleLabel = UILabel()
        detailTitleLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        detailTitleLabel.textColor = .white
        detailTitleLabel.font = UIFont.systemFont(ofSize: 12)
        detailTitleLabel.textAlignment = .center
        if state {
            detailTitleLabel.text = "즐겨찾기에 추가했어요"
        } else {
            detailTitleLabel.text = "즐겨찾기에서 삭제했어요"
        }
        view.addSubview(detailTitleLabel)

        UIView.animateKeyframes(withDuration: 2, delay: 0, options: [.allowUserInteraction]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                view.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 1.0, relativeDuration: 1.0) {
                view.alpha = 0
            }
        } completion: { _ in
            if let animationView = self.view.viewWithTag(2) {
                animationView.removeFromSuperview()
            }
        }
    }
    
    //MARK: - Selectors
    
    
    @objc
    public func detailBackButtonDidTap() {
        guard let viewcontrollers = self.navigationController?.viewControllers else { return }
        for viewcontroller in viewcontrollers {
            if viewcontroller is SuggestViewController {
                if let suggestViewController = viewcontroller as? SuggestViewController {
                    pushDetailInfo()
                    suggestViewController.suggestInfoDictionary = detailInfoDictionary
                    suggestViewController.suggestDataInfo = detailInfo
                    suggestViewController.suggestDetailFlag = detailFlag
                    suggestViewController.suggestKeyInfo = detailKeyInfo
                }
            } else if viewcontroller is ViewController {
                if let mainViewController = viewcontroller as? ViewController {
                    mainViewController.mainisFlag = detailFlag
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    public func suggestButtonDidTap() {
        let detailView = UIView()
        if detailFlag[selectIndex] {
            detailFlag[selectIndex] = false
            UserDefaults.standard.set(detailFlag, forKey: "mainisFlag")
            detailMovieUserSuggestButton.setImage(UIImage(named: "stardDisable"), for: .normal)
        } else {
            detailFlag[selectIndex] = true
            UserDefaults.standard.set(detailFlag, forKey: "mainisFlag")
            detailMovieUserSuggestButton.setImage(UIImage(named: "starEnable"), for: .normal)
        }
        stateSuggestView(state: detailFlag[selectIndex], View: detailView)
    }
}
