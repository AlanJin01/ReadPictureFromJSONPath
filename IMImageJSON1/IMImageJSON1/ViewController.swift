//
//  ViewController.swift
//  IMImageJSON1
//
//  Created by J K on 2019/1/29.
//  Copyright © 2019 KimsStudio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView: UITableView!
    
    var titles: [String] = [String]()  //临时存储标题
    var imgPaths: [Data] = [Data]()    //临时存储封面图路径
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let screen = UIScreen.main.bounds
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(ViewController.refreshBtn))
        self.navigationItem.title = "UP主:天天爱动漫-天天娘"
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screen.width, height: screen.height))
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        //清除缓存按钮
        let clearBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        clearBtn.center = CGPoint(x: screen.width - 80, y: screen.height - 100)
        clearBtn.backgroundColor = #colorLiteral(red: 0.3818765525, green: 0.5354764803, blue: 1, alpha: 1)
        clearBtn.layer.cornerRadius = 50
        clearBtn.setTitle("Clear", for: .normal)
        clearBtn.addTarget(self, action: #selector(ViewController.clearButton), for: .touchUpInside)
        self.view.addSubview(clearBtn)
        
        //创建保存h图片缓存文件的文件夹
        let folderPath = NSHomeDirectory() + "/Library/Caches/ImageCache"
        if !FileManager.default.fileExists(atPath: folderPath) {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("创建缓存文件夹出错")
            }
        }
       
        //读取网络数据
        jsonData()
    }
 
    //清除缓存
    @objc func clearButton() {
        let path = NSHomeDirectory() + "/Library/Caches"
        let subPath = FileManager.default.subpaths(atPath: path)
        
        //最好用Double类型
        var size: Double = 0.0
        
        //以下是计算缓存文件大小
        for subP in subPath! {
            let str = path.appendingFormat("/\(subP)")
            do {
                let attrib = try FileManager.default.attributesOfItem(atPath: str)
                for (a, b) in attrib {
                    if a == FileAttributeKey.size {
                        size += b as! Double
                    }
                }
            }catch {
                print("获取属性出错")
            }
        }
        //以下是清除缓存
        let size2 = Float(Int((size/1024/1024) * 100)) / 100
        let alertControl = UIAlertController(title: "缓存大小", message: "\(size2)MB", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "是", style: .default) { (action: UIAlertAction) -> Void in
            for subP in subPath! {
                let str = path.appendingFormat("/\(subP)")
                if FileManager.default.fileExists(atPath: str) {
                    do {
                        try FileManager.default.removeItem(atPath: str)
                    }catch {
                        print("清除缓存出错")
                    }
                }
            }
            print("已经清除缓存")
        }
        let cancelAction = UIAlertAction(title: "否", style: .destructive) { (action: UIAlertAction) -> Void in
        }
        alertControl.addAction(okAction)
        alertControl.addAction(cancelAction)
        self.present(alertControl, animated: true, completion: nil)
    }
    
    //刷新列表
    @objc func refreshBtn() {
        let aTitles = self.titles
        let aImgPaths = self.imgPaths
        self.titles = []
        self.imgPaths = []
        
        let folPath = NSHomeDirectory() + "/Librart/Caches/ImageCache"
        
        //如果用于存储缓存图片用的文件夹不存在时，创建相关文件夹
        if !FileManager.default.fileExists(atPath: folPath) {
            do {
                try FileManager.default.createDirectory(atPath: folPath, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("创建缓存用文件夹出错")
            }
        }
        
        //在此请求网络数据
        jsonData()
        
        //如果刷新后的数据跟上一次加载完的数据不相同的话，删除图片缓存文件
        if aTitles != self.titles && aImgPaths != self.imgPaths {
            let count = self.imgPaths.count
            for i in 0 ..< count {
                let path = NSHomeDirectory() + "/Library/Caches/ImageCache/img\(i).plist"
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    }catch {
                        print("删除图片plist出错")
                    }
                }
            }
        }
    }
    
    //解析json数据
    func jsonData() {
        let url = URL(string: "https://api.vc.bilibili.com/link_draw/v1/doc/doc_list?uid=322905135")
        let session = URLSession.shared
        let request = URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 20)
        let semaphore = DispatchSemaphore(value: 0) //设置信号量
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                let global = DispatchQueue.global()
                global.sync {
                    do {
                        let jsData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let dt = jsData["data"] as AnyObject
                        let items = dt["items"] as! [AnyObject]
                        
                        for i in 0 ..< items.count {
                            //标题
                            let title = items[i]["title"] as? String ?? " "
                            //封面图路径
                            let imgAttrib = items[i]["pictures"] as! [AnyObject]
                            let imgPath = imgAttrib[0]["img_src"] as? String ?? " "
                            let imgSetUrl = URL(string: imgPath)
                            let imgData = try! Data(contentsOf: imgSetUrl!)   //图片路径转换成Data类型

                            self.titles.append(title)  //添加到数组titles
                            self.imgPaths.append(imgData)  //添加到数组imgPaths
                        }
                    }catch {
                        print("解析有误")
                    }
                }
            }else {
                print("请求错误")
            }
            semaphore.signal()  //发送信号量
        }
        task.resume()  //执行任务
        semaphore.wait(timeout: DispatchTime.distantFuture)  //信号等待
        
        self.tableView.reloadData()   //更新列表
    }
    
    //===========================================================================
    //cell数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    //配置cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ReusedCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ImageCell
        if cell == nil {
            cell = ImageCell(style: .default, reuseIdentifier: identifier)
        }
        cell?.selectionStyle = .none
        
        if self.titles.count > 0 {
            cell?.label.text = self.titles[indexPath.row]
            cell?.imageViews.image = UIImage(data: self.imgPaths[indexPath.row])
        }
        return cell!
    }
    
    //cell行高
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    //选择某一cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secondView = SecondViewController()
        secondView.index = indexPath.row
        self.navigationController?.pushViewController(secondView, animated: true)
        
    }

}

