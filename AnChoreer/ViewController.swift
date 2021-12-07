//
//  ViewController.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/02.
//

import UIKit
import Alamofire

enum ViewStatus {
    case Empty
    case All
}

class ViewController: UIViewController,StateAnimateViewDelegate {
    
    //MARK: - Properties
    
    
    @IBOutlet weak var movieSearchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    public var resultDataModel:[SearchModelInfo] = []
    var ViewStatusType = ViewStatus.Empty
    var mainInfoDictionary:[Int:SearchModelInfo] = [:]
    var mainisFlag:[Bool] = []
    
    
    //MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    //MARK: - Helpers
    
    
    private func configure() {
        tableView.separatorColor = .lightGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.delegate = self
        tableView.dataSource = self
        let emptyNib = UINib(nibName: "AnchoreerEmptyTableViewCell", bundle: nil)
        tableView.register(emptyNib, forCellReuseIdentifier: "EmptyCell")
        let tableViewNib = UINib(nibName: "AnChoreerTableViewCell", bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: "AnChoreerCell")
        movieSearchBar.delegate = self
        movieSearchBar.clearButtonMode = .whileEditing
        let label = UILabel()
        label.text = "네이버 영화 검색"
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 23)
        
        let suggestButton = UIButton(type: .custom)
        suggestButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        suggestButton.setTitle("즐겨 찾기", for: .normal)
        suggestButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        suggestButton.setTitleColor(.black, for: .normal)
        suggestButton.setImage(UIImage(named: "star"), for: .normal)
        suggestButton.layer.borderColor = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 0.5).cgColor
        suggestButton.layer.borderWidth = 0.5
        suggestButton.layer.cornerRadius = 2
        suggestButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        let rightbarButtonItem = UIBarButtonItem.init(customView: suggestButton)
        rightbarButtonItem.customView?
            .widthAnchor
            .constraint(equalToConstant: 80)
            .isActive = true
        rightbarButtonItem.customView?
            .heightAnchor
            .constraint(equalToConstant: 30)
            .isActive = true
        suggestButton.addTarget(self, action: #selector(rightBarButtonDidTap), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = rightbarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    private func configureCell(indexpath indexPath: IndexPath) {
        if ViewStatusType == .All {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self = self else { return }
                guard let urlString = URL(string: self.resultDataModel[indexPath.row].image) else {
                    return
                }
                guard let data = try? Data(contentsOf: urlString), let image = UIImage(data: data) else {
                    return
                }
                let replaceStr = self.resultDataModel[indexPath.row].title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? AnChoreerTableViewCell {
                        self.tableView.isUserInteractionEnabled = true
                        self.tableView.isScrollEnabled = true
                        self.tableView.separatorColor = .lightGray
                        cell.movieImageView.image = image
                        cell.movieTitleLabel.text = replaceStr
                        cell.movieDirectorLabel.text = "감독: \(self.resultDataModel[indexPath.row].director)"
                        cell.movieActorLabel.text = "출연: \(self.resultDataModel[indexPath.row].actor == "" ? "값 비워있어요" : self.resultDataModel[indexPath.row].actor)"
                        
                        cell.movieUserRatingLabel.text = "평점: \(self.resultDataModel[indexPath.row].userRating)"
                        cell.movieUserSuggestButton.setImage(self.mainisFlag[indexPath.row] ? UIImage(named: "starEnable") : UIImage(named: "stardDisable"), for: .normal)
                        self.statusInfoData(self.mainisFlag[indexPath.row], indexpath: indexPath)
                        cell.suggestButtonClosure = { [weak self] in
                            guard let self = self else  { return }
                            let mainView = UIView()
                            self.mainisFlag[indexPath.row] = !self.mainisFlag[indexPath.row]
                            UserDefaults.standard.set(self.mainisFlag, forKey: "mainisFlag")
                            guard let mainisFlagInfo = UserDefaults.standard.array(forKey: "mainisFlag") as? [Bool] else { return }
                            self.stateSuggestView(state: self.mainisFlag[indexPath.row], View: mainView)
                            self.statusInfoData(self.mainisFlag[indexPath.row], indexpath: indexPath)
                            cell.movieUserSuggestButton.setImage(mainisFlagInfo[indexPath.row] ? UIImage(named: "starEnable") : UIImage(named: "stardDisable"), for: .normal)
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                if let emptyCell = self.tableView.cellForRow(at: indexPath) as? AnchoreerEmptyTableViewCell {
                    emptyCell.selectionStyle = .none
                    self.tableView.isUserInteractionEnabled = false
                    self.tableView.isScrollEnabled = false
                    self.tableView.separatorColor = .clear
                }
            }
        }
    }
    
    public func statusInfoData(_ status: Bool, indexpath: IndexPath) {
        if status {
            mainInfoDictionary.updateValue(self.resultDataModel[indexpath.row], forKey: indexpath.row)
        } else {
            mainInfoDictionary.removeValue(forKey: indexpath.row)
        }
    }
    
    
    public func pushMainInfo(indexpath indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let anchoreerDetailView = storyboard.instantiateViewController(withIdentifier: "AnChoreerDetailVC") as? AnChoreerDetailViewController
        guard let anchoreerDetailVC = anchoreerDetailView else { return }
        anchoreerDetailVC.suggestInfo = resultDataModel[indexPath.row]
        anchoreerDetailVC.selectIndex = indexPath.row
        anchoreerDetailVC.detailFlag = mainisFlag
        self.navigationController?.pushViewController(anchoreerDetailVC, animated: true)
    }
    
    func stateSuggestView(state: Bool ,View view: UIView) {
        view.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 5
        view.alpha = 0
        view.tag = 1
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
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        if state {
            titleLabel.text = "즐겨찾기에 추가했어요"
        } else {
            titleLabel.text = "즐겨찾기에서 삭제했어요"
        }
        view.addSubview(titleLabel)

        UIView.animateKeyframes(withDuration: 2, delay: 0, options: [.allowUserInteraction]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                view.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 1.0, relativeDuration: 1.0) {
                view.alpha = 0
            }
        } completion: { _ in
            if let animationView = self.view.viewWithTag(1) {
                animationView.removeFromSuperview()
            }
        }
    }
    
    
    //MARK: - Selectors
    
    
    @objc
    public func rightBarButtonDidTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let suggestView = storyboard.instantiateViewController(withIdentifier: "SuggestVC") as? SuggestViewController
        guard let suggestVC = suggestView else { return }
        suggestVC.suggestInfoDictionary = mainInfoDictionary
        suggestVC.suggestDetailFlag = mainisFlag
        self.navigationController?.pushViewController(suggestVC, animated: true)
    }
    
}


extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ViewStatusType {
        case .All:
            return resultDataModel.count
        case .Empty:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ViewStatusType {
        case .All:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnChoreerCell", for: indexPath) as! AnChoreerTableViewCell
            configureCell(indexpath: indexPath)
            return cell
        case .Empty:
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as? AnchoreerEmptyTableViewCell
            configureCell(indexpath: indexPath)
            return emptyCell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ViewStatusType {
        case .All:
            return UITableView.automaticDimension
        case .Empty:
            return tableView.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        pushMainInfo(indexpath: indexPath)
    }
    
}


extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.movieSearchBar.resignFirstResponder()
        if let text = textField.text, text != "" {
            let Parameter = [
                "query": text
            ]
            ResultAPI.getMovieList(Paramter: Parameter) { result in
                DispatchQueue.main.async {
                    self.resultDataModel = result
                    self.mainisFlag = Array(repeating: false, count: self.resultDataModel.count)
                    self.ViewStatusType = .All
                    self.tableView.reloadData()
                }
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.mainisFlag = []
        self.resultDataModel = []
        UserDefaults.standard.removeObject(forKey: "mainisFlag")
        ViewStatusType = .Empty
        self.tableView.reloadData()
        return true
    }
}



//MARK: - Protocol


protocol StateAnimateViewDelegate {
    func stateSuggestView(state: Bool, View view: UIView)
}
