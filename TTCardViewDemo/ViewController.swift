//
//  ViewController.swift
//  TTCardViewDemo
//
//  Created by zhang liangwang on 16/11/3.
//  Copyright © 2016年 zhangliangwang. All rights reserved.
//

import UIKit


//MARK:-屏幕高度和宽度
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height


//MARK:-UICollectionViewFlowLayout
class TTCardViewFlowLayout: UICollectionViewFlowLayout {
    
    let ActiveDistance: CGFloat = 350 //垂直缩放除以系数
    let ScaleFactor: CGFloat = 0.25 //缩放系数，越大缩放越大
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        //当前处理器能处理的最大浮点数
        var offsetAdjustment = CGFloat(MAXFLOAT)
        //collectionView落在屏幕中点的x坐标
        let horizontalCenter = proposedContentOffset.x + (self.collectionView!.bounds.size.width / 2.0)
        
        //目前cell的Rect
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.size.height)
        
        //目标区域中包含的cell
        let array = super.layoutAttributesForElements(in: targetRect) as [UICollectionViewLayoutAttributes]!
        
        for layoutAttributes in array! {
            let itemHorizontalCenter = layoutAttributes.center.x
            if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) { //ABS求绝对值
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y)
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        //rect范围内的cell视图
        let array = super.layoutAttributesForElements(in: rect)
        var visibleRect = CGRect()
        visibleRect.origin = self.collectionView!.contentOffset
        visibleRect.size = self.collectionView!.bounds.size
        
        for layoutAttributes in array! {
            let distance = visibleRect.midX - layoutAttributes.center.x
            let normalDistance = distance / ActiveDistance
            let zoom = 1 - ScaleFactor * (abs(normalDistance))
            let alpha = 1 - abs(normalDistance)
            layoutAttributes.transform3D = CATransform3DMakeScale(1.0, zoom, 1.0)
            layoutAttributes.alpha = alpha
            layoutAttributes.zIndex = 1
        }
        
        return array
    }
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // 滑动放大缩小，需实时刷新
        return true
    }
    
}


//MARK:-UICollectionViewCell
class TTCardViewCollectionViewCell: UICollectionViewCell {
    
    var productImageView: UIImageView!
    var productNameLabel: UILabel!
    var productPriceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        
        self.configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        
        let cellW: CGFloat = self.bounds.size.width
        let cellH: CGFloat = self.bounds.size.height
        let textH: CGFloat = cellH - cellW
        
        self.productImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cellW, height: cellW))
        self.addSubview(self.productImageView)
        
        self.productNameLabel = UILabel(frame: CGRect(x: 0, y: self.productImageView.frame.maxY, width: cellW, height: textH*2/3))
        self.productNameLabel.font = UIFont.systemFont(ofSize: 14)
        self.productNameLabel.textColor = UIColor.lightGray
        self.productNameLabel.textAlignment = .center
        self.productNameLabel.lineBreakMode = .byWordWrapping
        self.productNameLabel.numberOfLines = 2
        self.addSubview(self.productNameLabel)
        
        self.productPriceLabel = UILabel(frame: CGRect(x: 0, y: self.productNameLabel.frame.maxY, width: cellW, height: textH/3))
        self.productPriceLabel.font = UIFont.systemFont(ofSize: 14)
        self.productPriceLabel.textAlignment = .center
        self.productPriceLabel.textColor = UIColor.red
        self.addSubview(self.productPriceLabel)

        
        
    }
}

//class TTTestCell: UITableViewCell {
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}

class ViewController: UIViewController {

    
    var dataArray = [String]()
    var collectionView: UICollectionView!
    var numLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 背景
        let backImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        backImageView.isUserInteractionEnabled = true
        backImageView.image = UIImage.init(named: "bejin.jpg")
        self.view.addSubview(backImageView)
        
        // 提示
        self.numLabel = UILabel(frame: CGRect(x: 0, y: 25, width: ScreenWidth, height: 14))
        self.numLabel.text = "我的足迹（1 / 19）"
        self.numLabel.textColor = UIColor.black
        self.numLabel.textAlignment = .center
        self.numLabel.font = UIFont.systemFont(ofSize: 14)
        self.view.addSubview(self.numLabel)
        
        // data
        self.dataArray = ["test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg"]
        
        // UICollectionView
        let marginDistance: CGFloat = (ScreenWidth - 40)/5 + 20
        let itemW: CGFloat = (ScreenWidth - 40) * 3 / 5
        let itemH: CGFloat = ScreenHeight * 3 / 7
        
        let flowLayout = TTCardViewFlowLayout()
        flowLayout.itemSize = CGSize.init(width: itemW, height: itemH)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, marginDistance, 0, marginDistance)
        
        
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: ScreenWidth/3+30, width: ScreenWidth, height: itemH), collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(TTCardViewCollectionViewCell.self, forCellWithReuseIdentifier: "cardViewIdentifier")
        self.view.addSubview(self.collectionView)
        
        
        
    }
    
    // UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//MARK:-UICollectionViewDataSource&Delegate
extension ViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cardViewIdentifier", for: indexPath) as! TTCardViewCollectionViewCell
        
        cell.productImageView.image = UIImage(named: self.dataArray[indexPath.row])
        cell.productNameLabel.text = "多么炫酷的手机"
        cell.productPriceLabel.text = "$9.99"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("------\(indexPath.row)")
        
    }

}





















































































































