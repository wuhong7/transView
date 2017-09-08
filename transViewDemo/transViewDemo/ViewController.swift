//
//  ViewController.swift
//  transViewDemo
//
//  Created by 盖特 on 2017/8/31.
//  Copyright © 2017年 盖特. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var view1 : UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let redView = transView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        redView.backgroundColor = UIColor.red


        let greenView = transView(frame: CGRect(x: 200, y: 200, width: 200, height: 200))
        greenView.backgroundColor = UIColor.green
        
        self.view.addSubview(greenView)
        
        self.view1 = redView
        greenView.addSubview(redView)
        redView.canSuspendableIn(showView: greenView)
        greenView.canSuspendableIn(showView: self.view)

    }

    @IBAction func Click(_ sender: UIButton) {
        
        
        self.view1?.removeFromSuperview()
        self.view1 = nil
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

