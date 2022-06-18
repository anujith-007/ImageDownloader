//
//  ViewController.swift
//  ImageDowloader
//
//  Created by Anujith on 18/06/22.
//

import UIKit

class ViewController: UIViewController,URLSessionDelegate, URLSessionDownloadDelegate {
    
    @IBOutlet weak var pic1_ImageView: UIImageView!
    @IBOutlet weak var pic2_ImageView: UIImageView!
    @IBOutlet weak var pic3_ImageView: UIImageView!
    @IBOutlet weak var pic4_ImageView: UIImageView!
    @IBOutlet weak var progress1_Label: UILabel!
    @IBOutlet weak var progress2_Label: UILabel!
    @IBOutlet weak var progess3_Label: UILabel!
    @IBOutlet weak var progress_4Label: UILabel!
    @IBOutlet weak var progressView1: UIProgressView!
    @IBOutlet weak var progressView2: UIProgressView!
    @IBOutlet weak var progressView3: UIProgressView!
    @IBOutlet weak var progressView4: UIProgressView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var asyncBtn: UIButton!
    @IBOutlet weak var syncBtn: UIButton!
    
    var isSyncBtnSelected = true
    var urlStringArray:[String] = ["https://cdn.wallpapersafari.com/36/6/WCkZue.png","https://www.iliketowastemytime.com/sites/default/files/hamburg-germany-nicolas-kamp-hd-wallpaper_0.jpg","https://images.hdqwalls.com/download/drift-transformers-5-the-last-knight-qu-5120x2880.jpg","https://survarium.com/sites/default/files/calendars/survarium-wallpaper-calendar-february-2016-en-2560x1440.png"]
    
    var currentIndex = 0
    var currrentTask: URLSessionDownloadTask?
    var currentData:Data?
    var currentSession:URLSession?
    var currentTaskArray: [URLSessionDownloadTask] = [URLSessionDownloadTask]()
    var currentSessionArray:[URLSession] = [URLSession]()
    var currentDataArray:[Data] = [Data]()
    
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        syncBtn.backgroundColor = UIColor.blue
        syncBtn.setTitleColor(UIColor.white, for: .normal)
        asyncBtn.backgroundColor = UIColor.white
        asyncBtn.setTitleColor(UIColor.black, for: .normal)
    }
    
    //Button Click-----------------------------------------------------------------------------------------------------------------------------
    @IBAction func downloadBtnClicked(_ sender: Any) {
        syncBtn.isEnabled = false
        asyncBtn.isEnabled = false
        DispatchQueue.main.async {
            if self.downloadBtn.titleLabel?.text == "Start Download" {
                self.downloadBtn.setTitle("Pause", for: .normal)
                self.downloadImage()
            } else if self.downloadBtn.titleLabel?.text == "Pause" {
                if !self.isSyncBtnSelected {
//                    for i in 0..<self.currentTaskArray.count {
//                        self.currentTaskArray[i].cancel(byProducingResumeData: { data in
//                            if data != nil {
//                                self.currentDataArray.append(data!)
//                                DispatchQueue.main.async {
//                                    self.downloadBtn.setTitle("Resume", for: .normal)
//                                }
//                            }
//                        })
//                    }
                } else {
                    self.currrentTask?.cancel(byProducingResumeData: { data in
                        self.currentData = data
                        if self.currentData != nil {
                            DispatchQueue.main.async {
                                self.downloadBtn.setTitle("Resume", for: .normal)
                            }
                            
                        }
                    })
                }
            } else if self.downloadBtn.titleLabel?.text == "Resume" {
                if !self.isSyncBtnSelected {
//                    if !self.currentDataArray.isEmpty {
//                        for i in 0..<self.currentSessionArray.count {
//                            self.currentSessionArray[i].downloadTask(withResumeData: self.currentDataArray[i]).resume()
//                            DispatchQueue.main.async {
//                                self.downloadBtn.setTitle("Pause", for: .normal)
//                            }
//                        }
//                    }
                } else {
                    if self.currentData != nil {
                        self.currentSession?.downloadTask(withResumeData: self.currentData!).resume()
                        DispatchQueue.main.async {
                            self.downloadBtn.setTitle("Pause", for: .normal)
                        }
                    } else {
                    }
                }
                
            }
        }
        
    }
    
    @IBAction func syncBtnClicked(_ sender: Any) {
        syncBtn.backgroundColor = UIColor.blue
        syncBtn.setTitleColor(UIColor.white, for: .normal)
        asyncBtn.backgroundColor = UIColor.white
        asyncBtn.setTitleColor(UIColor.black, for: .normal)
        isSyncBtnSelected = true
    }
    
    @IBAction func asyncBtnClicked(_ sender: Any) {
        
        asyncBtn.backgroundColor = UIColor.blue
        asyncBtn.setTitleColor(UIColor.white, for: .normal)
        syncBtn.backgroundColor = UIColor.white
        syncBtn.setTitleColor(UIColor.black, for: .normal)
        
        isSyncBtnSelected = false
    }
    
    func downloadImage()   {
        if !isSyncBtnSelected {
            for index in 0..<urlStringArray.count {
                self.currentIndex = index
                let url = URL(string: self.urlStringArray[index])!

                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                
                session.downloadTask(with: url).resume()

            }
        } else {
            
            downloadImageSync(urlString: urlStringArray[0])
        }
    }
    
    func downloadImageSync(urlString: String) {
        DispatchQueue.main.async {
            
            let url = URL(string: urlString)!
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            session.downloadTask(with: url).resume()
        }
    }
    
    //URLSessionDelegate, URLSessionDownloadDelegate----------------------------------------------------------------------------------------------
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            let written = self.byteFormatter.string(fromByteCount: totalBytesWritten)
            let expected = self.byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
            let pro:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print("Downloaded \(written) / \(expected)")
            if self.isSyncBtnSelected {
                self.currrentTask = downloadTask
                self.currentSession = session
            } else {
                self.currentTaskArray.append(downloadTask)
                self.currentSessionArray.append(session)
            }
            
            DispatchQueue.main.async { [self] in
                print(downloadTask.response?.url?.absoluteString as Any)
                if downloadTask.response?.url?.absoluteString == self.urlStringArray[0] {
                    self.progressView1.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    self.progress1_Label.text = "\(Int(floor(pro * 100)))%"
                    print("\(Int(floor(pro * 100)))%")
                } else if downloadTask.response?.url?.absoluteString == self.urlStringArray[1] {
                    self.progressView2.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    self.progress2_Label.text = "\(Int(floor(pro * 100)))%"
                    print("\(Int(floor(pro * 100)))%")
                } else if downloadTask.response?.url?.absoluteString == self.urlStringArray[2] {
                    self.progressView3.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    self.progess3_Label.text = "\(Int(floor(pro * 100)))%"
                    print("\(Int(floor(pro * 100)))%")
                } else if downloadTask.response?.url?.absoluteString == self.urlStringArray[3] {
                    self.progressView4.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    self.progress_4Label.text = "\(Int(floor(pro * 100)))%"
                    print("\(Int(floor(pro * 100)))%")
                }
                
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
            print ("server error")
            DispatchQueue.main.async {
                if self.isSyncBtnSelected {
                    self.downloadBtn.setTitle("Finish", for: .normal)
                }
            }
            return
        }
        do {
            if let data = try?Data(contentsOf: location), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if downloadTask.response?.url?.absoluteString == self.urlStringArray[0] {
                        self.pic1_ImageView.contentMode = .scaleToFill
                        self.pic1_ImageView.clipsToBounds = true
                        self.pic1_ImageView.image = image
                        if self.isSyncBtnSelected {
                            self.currentIndex = 1
                            self.downloadImageSync(urlString: self.urlStringArray[1])
                        }
                    } else if downloadTask.response?.url?.absoluteString == self.urlStringArray[1] {
                        self.pic2_ImageView.contentMode = .scaleToFill
                        self.pic2_ImageView.clipsToBounds = true
                        self.pic2_ImageView.image = image
                        if self.isSyncBtnSelected {
                            self.currentIndex = 1
                            self.downloadImageSync(urlString: self.urlStringArray[2])
                        }
                    } else if downloadTask.response?.url?.absoluteString == self.urlStringArray[2] {
                        self.pic3_ImageView.contentMode = .scaleToFill
                        self.pic3_ImageView.clipsToBounds = true
                        self.pic3_ImageView.image = image
                        if self.isSyncBtnSelected {
                            self.currentIndex = 1
                            self.downloadImageSync(urlString: self.urlStringArray[3])
                        }
                    } else if downloadTask.response?.url?.absoluteString == self.urlStringArray[3] {
                        self.pic4_ImageView.contentMode = .scaleToFill
                        self.pic4_ImageView.clipsToBounds = true
                        self.pic4_ImageView.image = image
                        if self.isSyncBtnSelected {
                            self.downloadBtn.setTitle("Finish", for: .normal)
                        }
                    }
                }
                
            } else {
                fatalError("Cannot load the image")
                
            }

        }
        
        
    }
    
}

