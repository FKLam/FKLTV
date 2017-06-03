//
//  RoomViewController.swift
//  FKLTV
//
//  Created by kun on 2017/5/14.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit
import IJKMediaFramework

private let kChatToolsViewHeight: CGFloat = 44
private let kGiftListViewHeight: CGFloat = kScreenH * 0.5
private let kChatContentViewHeight: CGFloat = 200

class RoomViewController: UIViewController, Emitterable {

    // MARK: 控件属性
    fileprivate var bgImageView: UIImageView?
    
    fileprivate var chatToolsView: ChatToolsView!
    fileprivate var giftListView: GiftListView!
    fileprivate lazy var chatContentView: ChatContentView = {
        let chatContentView = ChatContentView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return chatContentView
    }()
    fileprivate lazy var socket: FKLSocket = FKLSocket(addr: "192.168.0.100", port: 7878)
    fileprivate var heartBeatTimer: Timer?
    
    fileprivate var ijkPlayer: IJKFFMoviePlayerController?
    var anchor: AnchorModel?
    
    fileprivate lazy var topButtonImages: [String] = {
        var topButtonImages: [String] = [String]()
        topButtonImages.append("room_btn_chat")
        topButtonImages.append("menu_btn_share")
        topButtonImages.append("room_btn_gift")
        topButtonImages.append("room_btn_more")
        topButtonImages.append("room_btn_qfstar")
        return topButtonImages
    }()
    
    // MARK: 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // 连接聊天服务器
        if socket.connectedServer() {
            print("服务器连接成功")
            socket.startReadMsg()
            addHeartBeatTimer()
            socket.sendJoinRoom()
            socket.delegate = self
        }
        
        // 请求主播信息
        loadAnchorLiveAddress()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        socket.sendLeaveRoom()
        ijkPlayer?.shutdown()
    }
    
    deinit {
        heartBeatTimer?.invalidate()
        heartBeatTimer = nil
    }
    
}

// MARK:- 设置UI界面

extension RoomViewController {
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.white
        bgImageView = UIImageView()
        bgImageView?.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)
        view.addSubview(bgImageView!)
        setupBlurView()
        setupTopView()
        setupTopBarView()
        setupBottomView()
    }
    
    private func setupBlurView() {
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurView.frame = bgImageView!.bounds
        bgImageView?.addSubview(blurView)
    }
    
    private func setupTopView() {
        let h: CGFloat = 44
        let topView = UIStackView(frame: CGRect(x: 0, y: kScreenH - h, width: kScreenW, height: h))
        view.addSubview(topView)
        let count = 5
        let w: CGFloat = kScreenW / 5
        var x: CGFloat = 0
        let y: CGFloat = 0
        for i in 0..<count {
            let btn = UIButton()
            btn.tag = i
            btn.frame = CGRect(x: x, y: y, width: w, height: h)
            let imageName = topButtonImages[i]
            btn.setImage(UIImage(named: imageName), for: .normal)
            btn.addTarget(self, action: #selector(topButtonClick(_:)), for: .touchUpInside)
            topView.addSubview(btn)
            x += w
        }
    }
    
    private func setupTopBarView() {
        let topY: CGFloat = 30
        let topX: CGFloat = 10
        let topH: CGFloat = 32
        let topW: CGFloat = 188
        let topView: UIView = UIView(frame: CGRect(x: topX, y: topY, width: topW, height: topH))
        topView.backgroundColor = .black
        view.addSubview(topView)
        
        let iconImage: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: topH, height: topH))
        topView.addSubview(iconImage)
        
        let w: CGFloat = 50
        let h: CGFloat = 50
        let y: CGFloat = 20
        var x: CGFloat = kScreenW - w - 10
        let closeButton: UIButton = UIButton(frame: CGRect(x: x, y: y, width: w, height: h))
        closeButton.setImage(UIImage.init(named: "menu_btn_close"), for: .normal)
        view.addSubview(closeButton)
        x -= w
        let peopleButton: UIButton = UIButton(frame: CGRect(x: x, y: y, width: w, height: h))
        peopleButton.setImage(UIImage.init(named: "zhibo_btn_people"), for: .normal)
        view.addSubview(peopleButton)
    }
    
    private func setupBottomView() {
        
        chatContentView.frame = CGRect(x: 0, y: kScreenH - 44 - kChatContentViewHeight, width: kScreenW, height: kChatContentViewHeight)
        chatContentView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(chatContentView)
        
        chatToolsView = ChatToolsView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: kChatToolsViewHeight))
        chatToolsView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        chatToolsView.delegate = self
        view.addSubview(chatToolsView)
        
        giftListView = GiftListView(frame: CGRect(x: 0, y: kScreenH, width: kScreenW, height: kGiftListViewHeight))
        giftListView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        giftListView.delegate = self
        view.addSubview(giftListView)
    }
}

// MARK:- 请求主播信息

extension RoomViewController {
    fileprivate func loadAnchorLiveAddress() {
        // 获取请求的地址
        let URLString = "http://qf.56.com/play/v2/preLoading.ios"
        
        // 获取请求的参数
        let parameters = ["imei": "", "signature": "", "roomId": anchor!.roomid, "userId": anchor!.uid] as [String : Any]
        NetworkTools.requestData(.get, URLString: URLString, parameters: parameters) { (result) in
            // 将result转成字典类型
            let resultDict = result as? [String: Any]
            
            // 从字典中取出数据
            let infoDict = resultDict?["message"] as? [String: Any]
            
            // 获取请求直播地址的URL
            guard let rURL = infoDict?["rUrl"] as? String else {
                return
            }
            
            // 请求直播地址
            NetworkTools.requestData(.get, URLString: rURL, finishedCallback: { (result) in
                let resultDict = result as? [String: Any]
                let liveURLString = resultDict?["url"] as? String
                
                self.displayLiveVie(liveURLString)
            })
            
        }
    }
    
    fileprivate func displayLiveVie(_ liveURLString: String?) {
        // 获取直播的地址
        guard let liveURLString = liveURLString else {
            return
        }
        
        // 使用IJKPlayer播放视频
        let options = IJKFFOptions.byDefault()
        options?.setOptionIntValue(1, forKey: "videotoolbox", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer = IJKFFMoviePlayerController(contentURLString: liveURLString, with: options)
        
        // 设置frame以及添加到其他view中
        if anchor?.push == 1 {
            ijkPlayer?.view.center = bgImageView!.center
            ijkPlayer?.view.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: bgImageView!.bounds.width, height: bgImageView!.bounds.width * 3 / 4.0))
        } else {
            ijkPlayer?.view.frame = bgImageView!.bounds
        }
        
        bgImageView?.addSubview(ijkPlayer!.view)
        ijkPlayer?.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // 开始播放
        ijkPlayer?.prepareToPlay()
    }
}

extension RoomViewController {
    fileprivate func startEmitter() {
        // 创建发射器
        let emitter = CAEmitterLayer()
        // 设置发射器的位置
        emitter.emitterPosition = CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height - 20)
        // 开启三维效果
        emitter.preservesDepth = true
        // 创建粒子，并且设置粒子相关属性
        let cell = CAEmitterCell()
        // 设置粒子速度
        cell.velocity = 150
        cell.velocityRange = 100
        // 设置粒子的大小
        cell.scale = 0.7
        cell.scaleRange = 0.3
        // 设置粒子方向
        cell.emissionLongitude = CGFloat(Double.pi / 2)
        cell.emissionRange = CGFloat(Double.pi / 2)
        // 设置粒子存活时间
        cell.lifetime = 6
        cell.lifetimeRange = 1.5
        // 设置粒子旋转
        cell.spin = CGFloat(Double.pi / 2)
        cell.spinRange = CGFloat(Double.pi / 2)
        // 设置粒子每秒弹出的个数
        cell.birthRate = 20
        // 设置粒子展示的图片
        cell.contents = UIImage(named: "good")?.cgImage
        // 将粒子设置到发射器中
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        
    }
}

// MARK:- 监听事件

extension RoomViewController {
    @objc fileprivate func topButtonClick(_ button: UIButton) {
        let tag = button.tag
        switch tag {
        case 0:
            chatToolsView.inputTextField.becomeFirstResponder()
            break
        case 1:
            break
        case 2:
            UIView.animate(withDuration: 0.25, animations: { 
                self.giftListView.frame.origin.y = kScreenH - kGiftListViewHeight
            })
            break
        case 3:
            break
        case 4:
            let point = CGPoint(x: button.center.x, y: kScreenH - button.bounds.height * 0.5)
            button.isSelected = !button.isSelected
            button.isSelected ? emitterableStart(point) : emitterableStop()
            break
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        chatToolsView.inputTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.giftListView.frame.origin.y = kScreenH
        })
    }
}

// MARK:- 监听键盘的弹出

extension RoomViewController {
    @objc fileprivate func keyboardWillChangeFrame(_ note: NSNotification) {
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let endFram = (note.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let inputViewY = endFram.origin.y - kChatToolsViewHeight
        UIView.animate(withDuration: duration) { 
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
            let endY = inputViewY == (kScreenH - kChatToolsViewHeight) ? kScreenH : inputViewY
            self.chatToolsView.frame.origin.y = endY
            let contentEndY = inputViewY == (kScreenH - kChatToolsViewHeight) ? (kScreenH - 44 - kChatContentViewHeight) : (endY - kChatContentViewHeight)
            self.chatContentView.frame.origin.y = contentEndY
        }
    }
}

// MARK:- ChatToolsViewDelegate

extension RoomViewController: ChatToolsViewDelegate {
    func chatToolsView(toolView: ChatToolsView, message: String) {
        socket.sendTextMsg(message: message)
    }
}

// MARK:- GiftListViewDelegate

extension RoomViewController: GiftListViewDelegate {
    func giftListView(giftView: GiftListView, giftModel: GiftModel) {
        socket.sendGiftMsg(giftName: giftModel.subject, giftUrl: giftModel.img2, giftCount: "1")
    }
}

// MARK:- 给服务器发送即时消息

extension RoomViewController {
    fileprivate func addHeartBeatTimer() {
        heartBeatTimer = Timer(fireAt: Date(), interval: 9, target: self, selector: #selector(sendHeartBeat), userInfo: nil, repeats: true)
        RunLoop.main.add(heartBeatTimer!, forMode: .commonModes)
    }
    
    @objc fileprivate func sendHeartBeat() {
        socket.sendHeartBeat()
    }
}

// MARK:- FKLSocketDelegate

extension RoomViewController: FKLSocketDelegate {
    func socket(_ socket: FKLSocket, chatMsg: TextMessage) {
        chatContentView.insertMsg(AttrStringGenerator.generateTextMessage(chatMsg.user.name!, chatMsg.text!))
    }
    
    func socket(_ socket: FKLSocket, giftMsg: GiftMessage) {
        let sendGiftMAttrMsg = AttrStringGenerator.generateGiftMessage(giftMsg.user.name!, giftMsg.giftname!, giftMsg.giftUrl!)
        chatContentView.insertMsg(sendGiftMAttrMsg)
    }
    
    func socket(_ socket: FKLSocket, joinRoom user: UserInfo) {
        chatContentView.insertMsg(AttrStringGenerator.generateJoinLeaveRoom(user.name!, true))
    }
    
    func socket(_ socket: FKLSocket, leaveRoom user: UserInfo) {
        chatContentView.insertMsg(AttrStringGenerator.generateJoinLeaveRoom(user.name!, false))
    }
}
