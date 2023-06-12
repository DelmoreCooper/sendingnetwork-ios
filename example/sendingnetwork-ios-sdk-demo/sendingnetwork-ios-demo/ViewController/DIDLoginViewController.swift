//
//  DIDLoginViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by chenghao on 2023/1/17.
//

import UIKit
import SnapKit
import web3
import SendingnetworkSDK

class DIDLoginViewController: BaseViewController {
    
        //Your privateKey
    let privateKey = "6f2e978b08db57348dacfdf48ddaee7586b95331e0db070472bbc16a3981887e"
    
    let walletAddress = "0x6F47cAf3270b14AB7242317a176ed8B69d393eBb"
    
    var did: String = ""
            
    private var listResponse: MXDIDListResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DID"
        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        view.addSubview(addressLable)
        view.addSubview(privateKeyLable)
        view.addSubview(didListButton)
        
        addressLable.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
        }
        
        privateKeyLable.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(addressLable.snp.bottom).offset(15)
        }
        
        didListButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
            make.top.equalTo(privateKeyLable.snp.bottom).offset(15)
        }
        
        view.addSubview(actionView)
        actionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(didListButton.snp.bottom).offset(15)
            make.height.equalTo(45)
        }
        
        actionView.addSubview(createDid)
        createDid.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(actionView.snp.bottom).offset(15)
            make.bottom.equalTo(-CGFloat.safeAreaBottom)
        }
    }
    
    private lazy var addressLable: UILabel = {
        let label = UILabel()
        label.font = .pingFangSCFont(ofSize: 15)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = "walletAddress: \(walletAddress)"
        return label
    }()
    
    private lazy var privateKeyLable: UILabel = {
        let label = UILabel()
        label.font = .pingFangSCFont(ofSize: 15)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = "privateKey: \(privateKey)"
        return label
    }()
    
    private lazy var didListButton: CHBigButton = {
        let button = CHBigButton()
        button.setTitle("DID list", for: .normal)
        button.addTarget(self, action: #selector(DIDList), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DIDTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 60
        return tableView
    }()
    
    private lazy var actionView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var createDid: CHButton = {
        let button = CHButton()
        button.setTitle("create_DID", for: .normal)
        button.addTarget(self, action: #selector(createDID), for: .touchUpInside)
        return button
    }()
    
//    @objc func DIDList() {
//        DIDClient.getDIDList(address: walletAddress) { result in
//            switch result {
//            case .success(let list):
//                debugPrint(list)
//            case .failure(let error):
//                debugPrint(error)
//            }
//        }
//    }
    
    
    @objc func DIDList() {
//        DIDClient.getDIDList(address: walletAddress) { result in
//            switch result {
//            case .success(let list):
//                debugPrint(list?.data)
//            case .failure(let error):
//                debugPrint(error)
//            }
//        }
        
        client?.getDIDList(walletAddress, success: { [weak self]  response in
            guard let self = self else { return }
            guard let response = response else { return }
            self.listResponse = response
            self.tableView.reloadData()
            debugPrint("didListCount: \(response.array.count)")
        }, failure: { error in
            debugPrint("error: \(error.debugDescription)")
        })
    }
    
    @objc func createDID() {
        client?.postCreateDID("did:pkh:eip155:1:\(walletAddress)", success: { [weak self] response in
            guard let self = self else { return }
            guard let response = response else { return }
            guard let message = response.message, let did = response.did, let updateTime = response.updated else { return }
            debugPrint("create did response: message-\(message),did-\(did),updateTime-\(updateTime)")
            self.did = did
            let alert = UIAlertController(title: "create did success", message: "message: \(message),\ndid:\(did),\nupdateTime:\(updateTime)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "sign and save", style: .default, handler: { [weak self] action in
                guard let self = self else { return }
                let signin = self.signinMessage(message: message)
                self.saveDID(did: did, params: ["signature":signin,"updated":updateTime,"operation":"create","address":"did:pkh:eip155:1:\(self.walletAddress)"])
            })
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }, failure: { error in
            debugPrint("create DID fail")
        })
    }
    
    func saveDID(did: String,params: [String:String]) {
        debugPrint("save did: did-\(did),params-\(params)")
        client?.postSaveDID(did, withParameter: params, success: {[weak self] response in
            guard let self = self else { return }
            guard let response = response else { return }
            debugPrint("save success\(response.message ?? "")")
            let alert = UIAlertController(title: "save success", message: "did: \(self.did)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            let loginAction = UIAlertAction(title: "Login_DID", style: .default, handler: { [weak self] action in
                guard let self = self else { return }
                self.pre_loginDID(did: self.did)
            })
            alert.addAction(okAction)
            alert.addAction(loginAction)
            self.present(alert, animated: true)
        }, failure: { error in
            debugPrint("save fail\(error.debugDescription)")
        })
    }
    
    func didInfo(did: String) {
        client?.getDIDInfo(did, success: { [weak self] listResponse in
            guard let self = self else { return }
            let didInfoVC = DIDInfoViewController()
            didInfoVC.didString = did
            didInfoVC.didInfo = listResponse
            self.navigationController?.pushViewController(didInfoVC, animated: true)
        }, failure: { error in
            debugPrint("save fail\(error.debugDescription)")

        })
    }
    
    func pre_loginDID(did: String) {
        let random = MXTools.generateSecret() ?? ""
        client?.postPreLoginDid(withParameter: ["did": did, "random": random], success: {[weak self] response in
            guard let self = self else { return }
            guard let response = response else { return }
            guard let message = response.message, let did = response.did, let updateTime = response.updated else { return }
            print("pre_log success")
            let random_server = response.random_server ?? ""
            let token = self.signinMessage(message: message)
            self.loginWithDID(identifier: ["did":did,"token":token], random: random, random_server: random_server, updateTime: updateTime)
        }, failure: { error in
            print("pre_log faile\(error.debugDescription)")
        })
    }
    
    func loginWithDID(identifier: [String: String], random: String, random_server: String, updateTime: String) {
        client?.postLoginDID(did, withParameter: [
            "type":"m.login.did.identity","updated":updateTime,"identifier":identifier,
            "random_server":random_server, "random":random
        ], success: { response in
            guard let response = response else { return }
            print("login success, user id: \(response.userId ?? ""), access_toke: \(response.accessToken ?? "")")
            let alert = UIAlertController(title: "login success", message: "user id: \(response.userId ?? "")\naccess_toke: \(response.accessToken ?? "")", preferredStyle: .alert)
            BaseSetting.shared.userId = response.userId
            BaseSetting.shared.access_token = response.accessToken
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
                guard let self = self else { return }
//                self.pushToTabbar()
                self.pushToLitTabbar()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }, failure: { error in
            print("login_did_error\(error.debugDescription)")
        })
    }
    
    func signinMessage(message: String) -> String {
        let keyStorage = EthereumKeyLocalStorage()
        let account = try? EthereumAccount.importAccount(replacing: keyStorage, privateKey: privateKey, keystorePassword: "")
        let sign = try? account?.signMessage(message:  Data(message.utf8))
        return sign!
    }
    
//    func hexStringToData(string: String) -> Data {
//        let stringArray = Array(string)
//        var data: Data = Data()
//        for i in stride(from: 0, to: string.count, by: 2) {
//            let pair: String = String(stringArray[i]) + String(stringArray[i+1])
//            if let byteNum = UInt8(pair, radix: 16) {
//                let byte = Data([byteNum])
//                data.append(byte)
//            }
//            else{
//                fatalError()
//            }
//        }
//        return data
//    }
    
    func pushToLitTabbar() {
        let tabbar = UITabBarController()
        let homeVC = HomeViewController()
        homeVC.navigationItem.title = "home"
        homeVC.tabBarItem.title = "home"
        homeVC.tabBarItem.image = UIImage.init(named: "tabbar_mine_normal")
        homeVC.tabBarItem.selectedImage = UIImage.init(named: "tabbar_mine_select")
        let homeNavi = UINavigationController(rootViewController: homeVC)

        
        let mineVC = MineViewController()
        mineVC.navigationItem.title = "mine"
        mineVC.tabBarItem.title = "mine"
        mineVC.tabBarItem.image = UIImage.init(named: "tabbar_mine_normal")
        mineVC.tabBarItem.selectedImage = UIImage.init(named: "tabbar_mine_select")
        let mineNavi = UINavigationController(rootViewController: mineVC)
        
        tabbar.viewControllers = [homeNavi,mineNavi]
        tabbar.selectedIndex = 0
        tabbar.tabBar.tintColor = .themeBlue
        UIWindow.keyWindow?.rootViewController = tabbar
    }
    
    func pushToTabbar() {
        let tabbar = UITabBarController()
        let messageVC = MessageViewController()
        messageVC.navigationItem.title = "message"
        messageVC.tabBarItem.title = "message"
        messageVC.tabBarItem.image = UIImage.init(named: "tabbar_mine_normal")
        messageVC.tabBarItem.selectedImage = UIImage.init(named: "tabbar_mine_select")
        let messageNavi = UINavigationController(rootViewController: messageVC)
        
        let roomVC = RoomViewController()
        roomVC.navigationItem.title = "room"
        roomVC.tabBarItem.title = "room"
        roomVC.tabBarItem.image = UIImage.init(named: "tabbar_mine_normal")
        roomVC.tabBarItem.selectedImage = UIImage.init(named: "tabbar_mine_select")
        let roomNavi = UINavigationController(rootViewController: roomVC)
        
        let contactVC = ContanctViewController()
        contactVC.navigationItem.title = "contact"
        contactVC.tabBarItem.title = "contact"
        contactVC.tabBarItem.image = UIImage.init(named: "tabbar_mine_normal")
        contactVC.tabBarItem.selectedImage = UIImage.init(named: "tabbar_mine_select")
        let contactNavi = UINavigationController(rootViewController: contactVC)
        
        let mineVC = MineViewController()
        mineVC.navigationItem.title = "mine"
        mineVC.tabBarItem.title = "mine"
        mineVC.tabBarItem.image = UIImage.init(named: "tabbar_mine_normal")
        mineVC.tabBarItem.selectedImage = UIImage.init(named: "tabbar_mine_select")
        let mineNavi = UINavigationController(rootViewController: mineVC)
        
        tabbar.viewControllers = [messageNavi,roomNavi,contactNavi,mineNavi]
        tabbar.selectedIndex = 0
        tabbar.tabBar.tintColor = .themeBlue
        UIWindow.keyWindow?.rootViewController = tabbar
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DIDLoginViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listResponse?.array?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DIDTableViewCell else {
            fatalError("Fail to dequeue a cell with identifier")
        }
        let didString = self.listResponse?.array?[indexPath.row] ?? ""
        cell.didLabel.text = didString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let didString = self.listResponse?.array?[indexPath.row] ?? ""
        let alert = UIAlertController(title: "DID:\(didString)", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "DID_login", style: .default) {[weak self] action in
            guard let self = self else { return }
            self.pre_loginDID(did: didString)
        }
        let infoAction = UIAlertAction(title: "DID_info", style: .default) {[weak self] action in
            guard let self = self else { return }
            self.didInfo(did: didString)
        }
        
        alert.addAction(infoAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    
}
