//
//  ViewController.swift
//  SegmentSwiftDemo
//
//  Created by LiuZhiwei on 2017/5/3.
//  Copyright © 2017年 LiuZhiwei. All rights reserved.
//

import UIKit


// 屏幕的物理宽度
let Screen_Width = UIScreen.main.bounds.size.width
// 屏幕的物理高度
let Screen_Height = UIScreen.main.bounds.size.height

// MARK:私有变量
var listView = UIScrollView.init()

/**
 * 当前（滑到）页
 */
var currentPage : NSInteger = 0

/**
 * 当前列表页的frame-X
 */
var currentX : CGFloat = 0.0

var isClick : Bool = false


class ViewController: UIViewController,UIScrollViewDelegate,SegmentSelectViewDelegate {

    var segmentView : SegmentSelectView! = nil
    
    // MARK: 系统方法
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initSubViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: 私有方法
    func initSubViews() {
        let titles : NSArray = self.getDatas()
        let segmentFrame : CGRect = CGRect.init(x: 0.0, y: 20.0, width: Screen_Width, height: 50)
        self.segmentView = SegmentSelectView.init(frame: segmentFrame)
        self.segmentView.backgroundColor = UIColor.init(red: 212/255.0, green: 245/255.0, blue: 253/255.0, alpha: 1.0)
        self.segmentView.seletColor = UIColor.init(red: 0/255.0, green: 180/255.0, blue: 227/255.0, alpha: 1.0)
        self.segmentView.normalColor = UIColor.init(red: 85/255.0, green: 90/255.0, blue: 100/255.0, alpha: 1.0)
        self.segmentView.bottomLineColor = UIColor.init(red: 0/255.0, green: 180/255.0, blue: 227/255.0, alpha: 1.0)
        self.segmentView.wordFont = 16.0
        self.segmentView.delegate = self
        self.view.addSubview(segmentView)
        self.segmentView.setTitlesDataWithArray(array: titles)
        
        listView = UIScrollView.init(frame: CGRect.init(x: 0, y: 70, width: Screen_Width, height: Screen_Height-70))
        listView.isPagingEnabled = true
        listView.delegate = self
        listView.bounces = false
        listView.showsHorizontalScrollIndicator = false
        listView.contentSize = CGSize.init(width: CGFloat(Int(titles.count))*Screen_Width, height: 0)
        self.view.addSubview(listView)
        
        for i in 0..<titles.count {
            let frame : CGRect = CGRect.init(x: CGFloat(Int(i))*Screen_Width, y: 0, width: Screen_Width, height: Screen_Height-70.0)
            let titleLab : UILabel = UILabel.init(frame: frame)
            let titleDic : NSDictionary = titles[i] as! NSDictionary
            titleLab.text = titleDic.value(forKey: "NAME") as! String?
            titleLab.backgroundColor = UIColor.black
            titleLab.textColor = UIColor.white
            titleLab.textAlignment = NSTextAlignment.center
            listView.addSubview(titleLab)
        }
    }
    
    // MARK: UIScrollViewDelegate 代理方法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isClick {
            self.segmentView.setBottomFrameWithScrollViewAndCurrentPageFrameX(scrollView: scrollView, frameX: currentX)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.segmentView.setTitleWithScrollViewAndCurrentPageFrameX(scrollView: scrollView, frameX: currentX)
        currentX = scrollView.contentOffset.x
        let index : NSInteger = NSInteger(CGFloat(currentX/Screen_Width))
        currentPage = index
        print("index: \(currentPage)")
        
        if isClick {
            isClick = false
        }
    }
    
   // MARK: SegmentSelectViewDelegate
    func buttonClickedWithIndex(index: NSInteger) {
        print("代理 index: \(index)")
        isClick = true
        listView.contentOffset = CGPoint.init(x: CGFloat(NSInteger(index))*Screen_Width, y: 0.0)
        self.scrollViewDidEndDecelerating(listView)
    }
    
    // MARK: 模拟数据
    func getDatas() -> NSArray  {
        let data = [["NAME":"要闻"],["NAME":"道"],["NAME":"人工智能科技"],["NAME":"汽车"],["NAME":"农业科技"],["NAME":"文学"],["NAME":"社会科学"],["NAME":"军事纪实"],["NAME":"自定义频道"],["NAME":"大数据技术"]];
        
        return data as NSArray;
    }
    
}


