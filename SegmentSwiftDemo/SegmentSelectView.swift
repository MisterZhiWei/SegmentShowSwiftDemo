//
//  SegmentSelectView.swift
//  SegmentSwiftDemo
//
//  Created by LiuZhiwei on 2017/5/3.
//  Copyright © 2017年 LiuZhiwei. All rights reserved.
//

import UIKit
/**
 * 分栏标题文字距离按钮两侧边距的距离
 */
let wordGap : CGFloat = 6.0

public protocol SegmentSelectViewDelegate :NSObjectProtocol {
  func buttonClickedWithIndex(index : NSInteger)
}

// MARK: 私有属性不可配置
/**
 * 分页栏底线
 */
var bottomLine : UIView = UIView.init()

/**
 * 分页栏承载滚动View
 */
var backScrollView :UIScrollView = UIScrollView.init()

var lastButton : UIButton = UIButton.init() // 上次选中按钮
var bottomLastX : CGFloat = 0.0
var titles : NSMutableArray = NSMutableArray.init()
var buttons : NSMutableArray = NSMutableArray.init()
var buttonWidths : NSMutableArray = NSMutableArray.init()
var buttonTotalWidth : CGFloat = 0.0

open class SegmentSelectView: UIView,UIScrollViewDelegate {
    weak open var delegate: SegmentSelectViewDelegate?
    /**
     * 选中栏目的字体颜色
     */
    open var seletColor : UIColor = UIColor.red
    
    /**
     * 底部选中线宽度 不设置时为默认值
     */
    open var bottomLineWidth : CGFloat = 20.0
    
    /**
     * 下边栏目的颜色
     */
    open var bottomLineColor : UIColor = UIColor.yellow
    
    /**
     * 选中栏目的字体颜色
     */
    //var seletColor : UIColor = UIColor.red
    
    /**
     * 默认栏目的字体颜色（即未选中栏目的字体颜色）
     */
    open var normalColor : UIColor = UIColor.gray
    
    /**
     * 栏目字体大小 默认14
     */
    open var wordFont : CGFloat = 14.0
    
    
    
    // MARK: 系统方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        backScrollView = UIScrollView.init(frame: self.bounds)
        backScrollView.showsHorizontalScrollIndicator = false
        backScrollView.delegate = self
        self.addSubview(backScrollView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 共有方法 供调用接口
    
    /**
     * 设置分栏标题
     */
    func setTitlesDataWithArray(array : NSArray) {
        if array.count > 0 {
            titles.removeAllObjects()
            titles.addObjects(from: array as! [Any])
            self.addSegmentButtonsWithTitles(titles: titles)
        }
    }
    
    /**
     * 手动滑动页面结束时，滑动到对应标题
     * parameter srollView 页面所在滑动的scrollView
     * parameter frameX    当前页面的frame.origin.x
     */
    func setTitleWithScrollViewAndCurrentPageFrameX(scrollView : UIScrollView , frameX : CGFloat) {
        var scrollGap : CGFloat = frameX - scrollView.contentOffset.x;
        if scrollView.contentOffset.x == 0 {
            scrollGap = 0;
        }
        let index : NSInteger = NSInteger(CGFloat (scrollView.contentOffset.x/Screen_Width))
        
        // 变更选中标题按钮
        lastButton.setTitleColor(normalColor, for: UIControlState.normal)
        let currentButton : UIButton = buttons[index] as! UIButton
        lastButton = currentButton
        currentButton.setTitleColor(seletColor, for: UIControlState.normal)
        
        // 变更底部选中线位置
        bottomLine.frame = CGRect.init(x: currentButton.frame.origin.x+((buttonWidths[index] as! CGFloat)-bottomLineWidth)/2, y: self.frame.size.height-2.0, width: bottomLineWidth, height: 2.0)
        bottomLastX = bottomLine.frame.origin.x;
        
        // 判断标签按钮是否在屏幕内
        let titleContentX : CGFloat = backScrollView.contentOffset.x;
        
        if scrollGap < 0 { // 向左滑动 判断右边分页按钮是否在屏幕内
            
            if index == titles.count - 1 {
                if (buttonTotalWidth >= Screen_Width) {
                    self.reSetTitleScrollViewOffsetWithX(pointX: buttonTotalWidth-Screen_Width)
                }
            }
            else {
                if titleContentX+Screen_Width < currentButton.frame.maxX+(buttonWidths[index+1] as! CGFloat) { // 右侧按钮不完全在屏幕内
                    let scrollGap : CGFloat = currentButton.frame.maxX+(buttonWidths[index+1] as! CGFloat) - titleContentX - Screen_Width;
                    self.reSetTitleScrollViewOffsetWithX(pointX: titleContentX+scrollGap)
                }
            }
        } else if scrollGap >= 0{ // 向右滑动 判断左边分页按钮是否在屏幕内
            if index == 0 {
                self.reSetTitleScrollViewOffsetWithX(pointX: 0.0)
            }
            else {
                if currentButton.frame.minX - titleContentX < (buttonWidths[index-1] as! CGFloat) {
                    let scrollGap : CGFloat = (buttonWidths[index-1] as! CGFloat) + titleContentX - currentButton.frame.minX
                    self.reSetTitleScrollViewOffsetWithX(pointX: titleContentX-scrollGap)
                }
            }
        }
    }
    
    /**
     * 手动滑动过程中移动底部选中线
     * parameter srollView 页面所在滑动的scrollView
     * parameter frameX    当前页面的frame.origin.x
     */
    func setBottomFrameWithScrollViewAndCurrentPageFrameX(scrollView : UIScrollView , frameX : CGFloat) {
        let scrollGap : CGFloat = frameX - scrollView.contentOffset.x
        let index : NSInteger = lastButton.tag
        if scrollGap < 0 { // 页面向左滑动 底部线向右滑动
            let scale : CGFloat = -scrollGap*2.0/Screen_Width
            let gap : CGFloat = ((buttonWidths[index] as! CGFloat)+(buttonWidths[index+1] as! CGFloat)-2*self.bottomLineWidth)/2 + bottomLineWidth;
            
            if scale <= 1 {
                bottomLine.frame = CGRect.init(x: bottomLine.frame.origin.x, y:  bottomLine.frame.origin.y, width: bottomLineWidth+scale*gap, height: 2.0)
            }
            else {
                bottomLine.frame = CGRect.init(x: bottomLastX+(scale-1)*gap, y: bottomLine.frame.origin.y, width: bottomLineWidth+gap-(scale-1)*gap, height: 2.0)
            }
            
        }
        else { // 页面向右滑动 底部线向左滑动
            let scale : CGFloat = scrollGap*2.0/Screen_Width;
            let gap : CGFloat = ((buttonWidths[index] as! CGFloat)+(buttonWidths[index-1] as! CGFloat)-2*bottomLineWidth)/2 + bottomLineWidth;
            if (scale <= 1) {
                bottomLine.frame = CGRect.init(x: bottomLastX-scale*gap, y: bottomLine.frame.origin.y, width: bottomLineWidth+scale*gap, height: 2.0)
            }
            else {
                bottomLine.frame = CGRect.init(x: bottomLastX-gap, y: bottomLine.frame.origin.y, width: bottomLineWidth+gap-(scale-1)*gap, height: 2.0)
            }
        }

    }

    // MARK: 私有方法
    /**
     * 根据标题数据添加按钮视图
     * button按钮说明：一般的标题栏按钮都是简单的文字显示所以用系统的button就够了，如果有特殊需求的可以封装后在这里引用
     */
    func addSegmentButtonsWithTitles(titles : NSMutableArray) {
        buttons.removeAllObjects()
        for subview in backScrollView.subviews {
            subview.removeFromSuperview()
        }
        
        for i in 0..<titles.count {
            let title : NSString = ((titles[i] as AnyObject).value(forKey: "NAME") as! NSString?)!
            let buttonWidth : CGFloat = CGFloat(Int(title.length)) * wordFont + 2.0*wordGap
            buttonWidths.add(buttonWidth)
            
            let titleButton : UIButton = UIButton.init(frame: CGRect.init(x: buttonTotalWidth, y: 0.0, width: buttonWidth, height: self.bounds.size.height))
            titleButton.titleLabel?.font = UIFont.systemFont(ofSize: wordFont)
            titleButton.setTitle(title as String, for: UIControlState.normal)
            titleButton.tag = i
            titleButton.addTarget(self, action: #selector(titleButtonClicked(button:)) , for: UIControlEvents.touchUpInside)
            buttonTotalWidth += buttonWidth
            
            if i==0 { // 选中按钮字体
                titleButton.setTitleColor(seletColor, for: UIControlState.normal)
                lastButton = titleButton
            }
            else {
                titleButton.setTitleColor(normalColor, for: UIControlState.normal)
            }
            
            titleButton.backgroundColor = UIColor.clear
            backScrollView.backgroundColor = UIColor.clear
            backScrollView.addSubview(titleButton)
            buttons.add(titleButton)
        }
        
        backScrollView.contentSize = CGSize.init(width: buttonTotalWidth, height: 0.0)
        // 添加底部选中线
        let bottomLineFrame : CGRect = CGRect.init(x: ((buttonWidths[0] as! CGFloat)-bottomLineWidth)/2, y: self.bounds.size.height-2, width: bottomLineWidth, height: 2.0)
        bottomLastX = wordGap
        bottomLine = UIView.init(frame: bottomLineFrame)
        bottomLine.backgroundColor = bottomLineColor
        backScrollView.addSubview(bottomLine)
    }
    
    // 分页栏按钮点击事件
    func titleButtonClicked(button : UIButton) {
        // 更新选中按钮
        lastButton.setTitleColor(normalColor, for: UIControlState.normal)
        lastButton = button
        button.setTitleColor(seletColor, for: UIControlState.normal)
        
        let index:NSInteger = button.tag
        
        // MARK: 执行代理方法
        delegate?.buttonClickedWithIndex(index: index)
        
        // 变更底部选中线位置
        let bottomLineFrame : CGRect = CGRect.init(x: button.frame.origin.x+((buttonWidths[index] as! CGFloat)-bottomLineWidth)/2, y: self.bounds.size.height-2, width: bottomLineWidth, height: 2.0)
        bottomLine.frame = bottomLineFrame
        bottomLastX = bottomLine.frame.origin.x
        
        let contentOffsetX : CGFloat = backScrollView.contentOffset.x
        let gap : CGFloat = button.center.x - contentOffsetX
        
        if gap < Screen_Width/2 { // 按钮距离屏幕左边近
            // 按钮左边距距离屏幕左边距的距离
            let leftGap : CGFloat = button.frame.minX - contentOffsetX
            
            if index == 0 { // 按钮为最左侧按钮 只把自己显示全即可
                self.reSetTitleScrollViewOffsetWithX(pointX: contentOffsetX+leftGap)
            }
            else {
                let leftButtonWidth : CGFloat = buttonWidths[index-1] as! CGFloat
                if leftGap < leftButtonWidth{ // 按钮距离左边距不足临近按钮距离 此时需要移动
                    print("向右滑动显示左侧按钮")
                    self.reSetTitleScrollViewOffsetWithX(pointX: contentOffsetX+leftGap-leftButtonWidth)
                }
            }
            
            
        }
        else if gap > Screen_Width/2 {
            // 按钮右边距距离屏幕右边距的距离
            let rightGap : CGFloat = contentOffsetX+Screen_Width-button.frame.maxX
            if index == titles.count-1 { // 当前是最右侧按钮
                self.reSetTitleScrollViewOffsetWithX(pointX: contentOffsetX-rightGap)
            }
            else {
                let rightButtonWidth : CGFloat = buttonWidths[index+1] as! CGFloat
                if rightGap < rightButtonWidth { // 按钮距离右边距不足一个按钮距离 此时需要移动
                    self.reSetTitleScrollViewOffsetWithX(pointX: contentOffsetX+rightButtonWidth-rightGap)
                }
            }
            
        }
        
    }
    
    func reSetTitleScrollViewOffsetWithX(pointX : CGFloat) {
        UIView.animate(withDuration: 0.3) { 
            backScrollView.contentOffset = CGPoint.init(x: pointX, y: 0)
        }
    }
    
}
