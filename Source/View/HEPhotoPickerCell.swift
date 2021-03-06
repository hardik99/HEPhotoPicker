//
//  HEPhotoPickerCell.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/19.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit
import Photos
typealias HEPhotoPickerCellClosure = (_ btn: UIButton)->Void
typealias HEPhotoPickerCellAlter = ()->Void
class HEPhotoPickerCell: UICollectionViewCell {
    
    var imageView : UIImageView!
    var checkBtn  : UIButton!
    var topView : UIView!
    var durationLab : UILabel!
    var durationBackView : UIView!
    var maskLayer : CAGradientLayer!
    var checkBtnnClickClosure : HEPhotoPickerCellClosure?
    var topViewClickBlock : HEPhotoPickerCellAlter?
    var representedAssetIdentifier : String!
    var model : HEPhotoPickerListModel!{
        didSet{
            imageView.image = UIImage()
            if model.isEnableSelected {
                checkBtn.isHidden =  false
               
            }else{
                checkBtn.isHidden =  true
            }
            checkBtn.isSelected =  model.isSelected
            topView.isHidden =  model.isEnable
            let options = PHImageRequestOptions()
            let scale : CGFloat = 1.5
            self.representedAssetIdentifier = model.asset.localIdentifier
            let   thumbnailSize = CGSize(width: self.bounds.size.width * scale, height: self.bounds.size.height  * scale )
            PHImageManager.default().requestImage(for: model.asset,
                                                  targetSize:thumbnailSize,
                                                  contentMode: .aspectFill,
                                                  options: options)
            { (image, nil) in
                DispatchQueue.main.async {
                    if self.representedAssetIdentifier == self.model.asset.localIdentifier{
                        
                        self.imageView.image = image
                    }
                }
            }
            
            if model.asset.mediaType == .video{
                durationBackView.isHidden = false
                let timeStamp = lroundf(Float(self.model.asset.duration))
                
                let s = timeStamp % 60
                
                let m = (timeStamp - s) / 60 % 60
                
              
                let time = String(format: "%.2d:%.2d",  m, s)
                durationLab.text = time
                self.layoutSubviews()
            }else{
                 durationBackView.isHidden = true
            }
        }
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.gray
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        checkBtn = UIButton.init(type: .custom)
        let budle = Bundle(path: Bundle(for: HEPhotoBrowserViewController.self).path(forResource: "HEPhotoPicker", ofType: "bundle")!)!
        let selImage = UIImage(named: "btn-check-selected", in: budle, compatibleWith: nil)
        let norImage = UIImage(named: "btn-check-normal", in: budle, compatibleWith: nil)
        checkBtn.setImage(selImage, for: .selected)
        checkBtn.setImage(norImage, for: .normal)
        checkBtn.addTarget(self, action: #selector(selectedBtnClick(_:)), for: .touchUpInside)
        contentView.addSubview(checkBtn)
        
        topView = UIView()
        topView.isHidden = true
        topView.backgroundColor = UIColor.init(r: 255, g: 255, b:255, a: 0.6)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(topViewClick))
        contentView.addSubview(topView)
        topView.addGestureRecognizer(tap)
        
        
        durationBackView = UIView()
        durationBackView.backgroundColor = UIColor.clear
        durationBackView.isHidden = true
        contentView.addSubview(durationBackView)
        maskLayer = CAGradientLayer()
        maskLayer.colors = [UIColor.clear.cgColor,UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor]
        maskLayer.startPoint = CGPoint.init(x: 0, y: 0)
        maskLayer.endPoint = CGPoint.init(x: 0, y: 1)
        maskLayer.locations = [0,1]
        maskLayer.borderWidth = 0
        durationBackView.layer.addSublayer(maskLayer)
        
        durationLab = UILabel()
        durationLab.font = UIFont.systemFont(ofSize: 10)
        durationLab.textColor = UIColor.white
    
        durationBackView.addSubview(durationLab)
       
    }
    
    @objc func topViewClick() {
        if let blcok = topViewClickBlock{
            blcok()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
        let btnW : CGFloat = 25
        checkBtn.frame = CGRect.init(x: self.bounds.width - 5 - btnW, y: 5, width: btnW, height: btnW)
        topView.frame = contentView.bounds
        let durationBackViewH = CGFloat(20)
        durationBackView.frame = CGRect.init(x: 0, y: self.bounds.height - durationBackViewH, width: self.bounds.width, height: durationBackViewH)
        durationLab.sizeToFit()
        
        durationLab.frame = CGRect.init(x: durationBackView.bounds.width - durationLab.bounds.width - 5, y: (durationBackViewH - durationLab.bounds.height)/2.0, width: durationLab.bounds.width, height: durationLab.bounds.height)
        maskLayer.frame = self.durationBackView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func selectedBtnClick(_ btn: UIButton){
        
        if let closure = checkBtnnClickClosure {
            closure(btn)
        }
    }
}
