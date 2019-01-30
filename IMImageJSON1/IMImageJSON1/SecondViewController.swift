//
//  SecondViewController.swift
//  IMImageJSON1
//
//  Created by J K on 2019/1/30.
//  Copyright © 2019 KimsStudio. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var index: Int = Int()  //用来检测用户选择了第几行的cell
    
    var tableView: UITableView!
    
    var imgPaths: [Data] = [Data]()  //存储图片
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let screen = UIScreen.main.bounds
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screen.width, height: screen.height))
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let path = NSHomeDirectory() + "/Library/Caches/ImageCache"
        
        //如果用于存储缓存图片用的文件夹不存在时，创建相关文件夹
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("创建缓存用文件夹出错")
            }
        }
        
        let cachePath = path.appendingFormat("/img\(self.index).plist")
        
        if !FileManager.default.fileExists(atPath: cachePath) {   //把解析出来的数据存储到plist文件中
            jsonData()
            var imArray = Array<Data>()
            imArray = self.imgPaths
            let imNSArray = imArray as NSArray
            imNSArray.write(toFile: cachePath, atomically: true)  //写入plist文件，用来缓存
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cachePath = NSHomeDirectory() + "/Library/Caches/ImageCache/img\(self.index).plist"
        print(cachePath)
        
        if FileManager.default.fileExists(atPath: cachePath) {   //从缓存中提取数据
            let data = NSArray(contentsOfFile: cachePath)
            self.imgPaths = data as! [Data]
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
                        
                        //获取图片路径
                        let imgAttrib = items[self.index]["pictures"] as! [AnyObject]
                        for i in 0 ..< imgAttrib.count {
                            let imgPath = imgAttrib[i]["img_src"] as? String ?? " "
                            let imgSetUrl = URL(string: imgPath)
                            let imgData = try! Data(contentsOf: imgSetUrl!)   //图片路径转换成Data类型
                            
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
    
    
    //cell数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgPaths.count
    }
    
    //cell行高
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    //配置cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "ReusedCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? ImageCell
        if cell == nil {
            cell = ImageCell(style: .default, reuseIdentifier: id)
        }
        cell?.selectionStyle = .none
        cell?.imageViews.frame = CGRect(x: 10, y: 15, width: 400, height: 230)
        
        if self.imgPaths.count > 0 {
            cell?.imageViews.image = UIImage(data: self.imgPaths[indexPath.row])
        }
        
        return cell!
    }
}
