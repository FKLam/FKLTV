//
//  GiftListView.swift
//  FKLTV
//
//  Created by kun on 2017/5/20.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

private let kGiftCellID = "kGiftCellID"

protocol GiftListViewDelegate: class {
    func giftListView(giftView: GiftListView, giftModel: GiftModel)
}

class GiftListView: UIView {
    fileprivate var giftView: UIView!
    fileprivate var sendGiftBtn: UIButton!
    fileprivate var pageCollectionView: FKLPageCollectionView!
    fileprivate var currentIndexPath: IndexPath?
    weak var delegate: GiftListViewDelegate?
    fileprivate let giftVM: GiftViewModel = GiftViewModel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- 设置UI界面

extension GiftListView {
    fileprivate func setupUI() {
        backgroundColor = UIColor.black
        setupGifView()
        loadGiftData()
    }
    
    fileprivate func setupGifView() {
        let giftLabelX: CGFloat = 10
        let giftLabelY: CGFloat = 0
        let giftLabelW: CGFloat = 100
        let giftLabelH: CGFloat = 30
        let giftLabel = UILabel(frame: CGRect(x: giftLabelX, y: giftLabelY, width: giftLabelW, height: giftLabelH))
        giftLabel.font = UIFont.systemFont(ofSize: 10)
        giftLabel.textColor = UIColor.white
        giftLabel.text = "赠送礼物"
        giftLabel.textAlignment = .left
        addSubview(giftLabel)
        
        let priceBtnW: CGFloat = 50
        let priceBtnH: CGFloat = 30
        let priceBtnY: CGFloat = 0
        let priceBtnX: CGFloat = kScreenW - priceBtnW
        let priceBtn = UIButton(frame: CGRect(x: priceBtnX, y: priceBtnY, width: priceBtnW, height: priceBtnH))
        priceBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        priceBtn.setTitleColor(UIColor.orange, for: .normal)
        priceBtn.setTitle("充值", for: .normal)
        addSubview(priceBtn)
        
        let leavePriceLabelW: CGFloat = 100
        let leavePriceLabelH: CGFloat = 30
        let leavePriceLabelY: CGFloat = 0
        let leavePriceLabelX: CGFloat = priceBtnX - leavePriceLabelW
        let leavePriceLabel = UILabel(frame: CGRect(x: leavePriceLabelX, y: leavePriceLabelY, width: leavePriceLabelW, height: leavePriceLabelH))
        leavePriceLabel.font = UIFont.systemFont(ofSize: 12)
        leavePriceLabel.textColor = UIColor.white
        leavePriceLabel.textAlignment = .right
        leavePriceLabel.text = "余额：／"
        addSubview(leavePriceLabel)
        
        let separatorLine = UIView(frame: CGRect(x: 0, y: 30, width: kScreenW, height: 1))
        separatorLine.backgroundColor = UIColor.orange
        addSubview(separatorLine)
        
        let giftViewX: CGFloat = 0
        let giftViewY: CGFloat = 30 + 1
        let giftViewW: CGFloat = kScreenW
        let giftViewH: CGFloat = 250
        giftView = UIView(frame: CGRect(x: giftViewX, y: giftViewY, width: giftViewW, height: giftViewH))
        addSubview(giftView)
        
        let style = FKLTitleStyle()
        style.isScrollEable = false
        style.isShowScrollLine = true
        style.normalColor = UIColor(r: 255, g: 255, b: 255)
        
        let layout = FKLPageCollectionViewLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.cols = 4
        layout.rows = 2
        
        var pageViewFrame = giftView.bounds
        pageViewFrame.size.width = kScreenW
        pageCollectionView = FKLPageCollectionView(frame: pageViewFrame, titles: ["热门", "高级", "豪华", "专属"], style: style, isTitleInTop: true, layout: layout)
        giftView.addSubview(pageCollectionView)
        pageCollectionView.dataSource = self
        pageCollectionView.delegate = self
        
        pageCollectionView.register(cell: GiftViewCell.self, identifier: kGiftCellID)
        
        let sendLabelX: CGFloat = 10
        let sendLabelH: CGFloat = 30
        let sendLabelW: CGFloat = 100
        let sendLabelY: CGFloat = bounds.height - sendLabelH
        let sendLabel = UILabel(frame: CGRect(x: sendLabelX, y: sendLabelY, width: sendLabelW, height: sendLabelH))
        sendLabel.text = "赠送"
        sendLabel.textColor = UIColor.white
        sendLabel.textAlignment = .left
        sendLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(sendLabel)
        
        let sendGiftBtnW: CGFloat = 60
        let sendGiftBtnH: CGFloat = 30
        let sendGiftBtnX: CGFloat = kScreenW - sendGiftBtnW - 10
        let sendGiftBtnY: CGFloat = bounds.height - sendGiftBtnH - 10
        sendGiftBtn = UIButton(frame: CGRect(x: sendGiftBtnX, y: sendGiftBtnY, width: sendGiftBtnW, height: sendGiftBtnH))
        sendGiftBtn.backgroundColor = UIColor.orange
        sendGiftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sendGiftBtn.setTitleColor(UIColor.white, for: .normal)
        sendGiftBtn.setTitle("赠送", for: .normal)
        addSubview(sendGiftBtn)
        sendGiftBtn.isEnabled = false
        sendGiftBtn.addTarget(self, action: #selector(sendGiftBtnClick(_:)), for: .touchUpInside)
    }
}

// MARK:- 加载数据

extension GiftListView {
    fileprivate func loadGiftData() {
        giftVM.loadGiftData { 
            self.pageCollectionView.reloadData()
        }
    }
}

// MARK:- 送礼物

extension GiftListView {
    @objc fileprivate func sendGiftBtnClick(_ sender: UIButton) {
        let package = giftVM.giftlistData[currentIndexPath!.section]
        let giftModel = package.list[currentIndexPath!.item]
        delegate?.giftListView(giftView: self, giftModel: giftModel)
    }
}

// MARK:- FKLPageCollectionViewDataSource

extension GiftListView: FKLPageCollectionViewDataSource {
    func numberOfSections(in pageCollectionView: FKLPageCollectionView) -> Int {
        return giftVM.giftlistData.count
    }
    
    func pageCollectionView(_ collectionView: FKLPageCollectionView, numberOfItemsInSection section: Int) -> Int {
        let package = giftVM.giftlistData[section]
        return package.list.count
    }
    
    func pageCollectionView(_ pageCollectionView: FKLPageCollectionView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kGiftCellID, for: indexPath) as! GiftViewCell
        let package = giftVM.giftlistData[indexPath.section]
        let giftModel = package.list[indexPath.item]
        cell.giftModel = giftModel
        return cell
    }
}

// MARK:- FKLPageCollectionViewDelegate

extension GiftListView: FKLPageCollectionViewDelegate {
    func pageCollectionView(_ collectionView: FKLPageCollectionView, didSelectItemAt indexPath: IndexPath) {
        sendGiftBtn.isEnabled = true
        currentIndexPath = indexPath
    }
}
