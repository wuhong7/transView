//
//  Suspendable.swift
//  transViewDemo
//
//  Created by 盖特 on 2017/8/31.
//  Copyright © 2017年 盖特. All rights reserved.
//

import UIKit

private var showViewKey = "showViewKey"
private var suspendMarginKey = "suspendMarginKey"

protocol Suspendable : class {
    
}

extension Suspendable where Self : UIView {

    func canSuspendableIn(showView : UIView , clipsToBounds : Bool = true){
        //添加属性
        self.showView = showView
        self.showView.clipsToBounds = clipsToBounds
        //添加手势
        let moveGes:UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(dragBallView(panGes:)))
        self.addGestureRecognizer(moveGes)
        //添加showView frame变化的观察者
        self.addObserverEvent()
        
    }
    
    func removeObserverEvent(){
        self.showView.removeObserver(self, forKeyPath: "frame")
    }

}

extension UIView{
    
    fileprivate func addObserverEvent(){
        
        self.showView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath! as NSString).isEqual(to: "frame") {
            
            let oldBounds = change![NSKeyValueChangeKey.oldKey] as! CGRect
            let newBounds = change![NSKeyValueChangeKey.newKey] as! CGRect
            
            print("oldBounds-\(oldBounds)")
            print("newBounds-\(newBounds)")
            
            //获取x的转换值
            let Bx = self.center.x/oldBounds.width * newBounds.width
            self.center.x = Bx
            //获取y的转换值
            let By = self.center.y/oldBounds.height * newBounds.height
            self.center.y = By
            
            self.adjustPosition()
        }

    }
  
    
}


fileprivate extension UIView{

    //动态添加属性
    var showView: UIView {
        get {
            
            if let showView = objc_getAssociatedObject(self, &showViewKey) as? UIView {
                return showView
            }
            let initValue = UIApplication.shared.keyWindow!
            objc_setAssociatedObject(self, &showViewKey, initValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return initValue
        }
        set {
            objc_setAssociatedObject(self, &showViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var suspendMargin: CGFloat {
        get {
            
            if let suspendMargin = objc_getAssociatedObject(self, &suspendMarginKey) as? CGFloat {
                return suspendMargin
            }
            let initValue : CGFloat = 10
            objc_setAssociatedObject(self, &suspendMarginKey, initValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return initValue
        }
        set {
            objc_setAssociatedObject(self, &suspendMarginKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    ///跟随手指拖动
    @objc func dragBallView(panGes:UIPanGestureRecognizer) {
        
        var translation = panGes.translation(in: panGes.view)
        
        var x = self.center.x + translation.x
        var y = self.center.y + translation.y
        let centerPoint = CGPoint(x: x, y: y)
        switch panGes.state {
        case .began:
            fallthrough
        case .changed:
            
            guard self.showView.bounds.contains(centerPoint) else {
                
                if y <= 0 || y > self.showView.bounds.maxY{
                    y = y <= 0 ? 0 : self.showView.bounds.maxY
                }else{
                    //清空y位移
                    translation.y = 0
                }
                if x <= 0 || x > self.showView.bounds.maxX{
                    x = x <= 0 ? 0 : self.showView.bounds.maxX
                }else{
                    //清空x位移
                    translation.x = 0
                }
                self.center = CGPoint(x: x, y: y)
                panGes.setTranslation(translation, in: panGes.view)
                
                return
            }
            
            self.center = centerPoint
            
            panGes.setTranslation(CGPoint.zero, in: panGes.view)
        case .ended: fallthrough
        case .cancelled: fallthrough
        case .failed:
            print("取消手势")
            adjustPosition()
            
        default:
            print("默认")
        }
        
    }
    
    ///自动调整位置
    func adjustPosition(){
        //判断自己是否在区域内
        guard !self.showView.bounds.contains(self.frame) else {
            print("在区域内")
            return
        }
        
        print("不在域内")
        //调整到可显示区域
        var targetCenter = CGPoint.zero
        //超出父视图 左侧
        if self.center.x <= self.bounds.width/2 + self.suspendMargin {
            
            //上
            if self.center.y <= self.bounds.height/2 + self.suspendMargin{
                targetCenter = CGPoint(x: self.bounds.width/2 + self.suspendMargin, y: self.bounds.height/2 + self.suspendMargin)
            }
            
            //中
            else if self.bounds.height/2 + self.suspendMargin < self.center.y  && self.center.y <= self.showView.bounds.height - self.bounds.height/2 - self.suspendMargin{
                targetCenter = CGPoint(x: self.bounds.width/2 + self.suspendMargin, y: self.center.y)
            }
            
            //下
            else{
                targetCenter = CGPoint(x: self.bounds.width/2 + self.suspendMargin, y: self.showView.bounds.height - self.bounds.height/2 - self.suspendMargin)
            }
            
        }
        //超出父视图 右侧
        else if self.center.x >= self.showView.bounds.width - self.bounds.width/2 - self.suspendMargin {
            
            //上
            if self.center.y <= self.bounds.height/2 + self.suspendMargin{
                targetCenter = CGPoint(x: self.showView.bounds.width - self.bounds.width/2 - self.suspendMargin,
                                      y: self.bounds.height/2 + self.suspendMargin)
            }
                
            //中
            else if self.bounds.height/2 + self.suspendMargin < self.center.y  && self.center.y <= self.showView.bounds.height - self.bounds.height/2 - self.suspendMargin{
                targetCenter = CGPoint(x: self.showView.bounds.width - self.bounds.width/2 - self.suspendMargin,
                                      y: self.center.y)
            }
                
            //下
            else{
                targetCenter = CGPoint(x: self.showView.bounds.width - self.bounds.width/2 - self.suspendMargin,
                                      y: self.showView.bounds.height - self.bounds.height/2 - self.suspendMargin)
            }
            
        }
        //超出父视图上
        else if self.center.y <= self.bounds.height/2 + self.suspendMargin {
            targetCenter = CGPoint(x: self.center.x,
                                  y: self.bounds.height/2 + self.suspendMargin)
            
        }
        //超出父视图下
        else{
            targetCenter = CGPoint(x: self.center.x,
                                  y: self.showView.bounds.height - self.bounds.height/2 - self.suspendMargin)
        }
        
        //动画移动到指定的目标地点
        UIView.animate(withDuration: 0.5) { 
            self.center = targetCenter
        }

    }
    
}



