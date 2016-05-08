//
//  ViewController.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 27.04.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import UIKit
class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var searchedTextField: UITextField!
    @IBOutlet weak var maxResultsTextField: UITextField!
    @IBOutlet weak var maxDeepTextField: UITextField!
    @IBOutlet weak var maxFlowTextField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var tapGestureRecognizer: UITapGestureRecognizer! 
    weak var model: MSVSimpleWebCrawlerSpiderModel? = nil

    func go()->Void
    {
        self.tapView()
        self.testTextField()
        self.model!.start()
    }
    
    @IBAction func go(sender: AnyObject) {
        go()
    }

    @IBAction func pause(sender: AnyObject) {
        self.tapView()
        self.model!.pause()
    }

    @IBAction func resume(sender: AnyObject) {
        self.tapView()
        self.model!.resume()
    }

    @IBAction func stop(sender: AnyObject) {
        self.tapView()
        self.model!.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.model = MSVSimpleWebCrawlerSpiderModel.sharedModel()
        self.model!.delegate = self
        model!.addObserver(self, forKeyPath: "currentStatus", options: [], context: nil)
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapView))
        self.view!.addGestureRecognizer(self.tapGestureRecognizer)
        self.tapGestureRecognizer.delegate = self
        self.reconnectView(urlTextField)
        self.reconnectView(searchedTextField)
        self.reconnectView(maxResultsTextField)
        self.reconnectView(maxDeepTextField)
        self.reconnectView(maxFlowTextField)
        self.reconnectView(goButton)
        self.reconnectView(pauseButton)
        self.reconnectView(resumeButton)
        self.reconnectView(stopButton)
        self.reconnectView(infoLabel)
        self.reconnectView(tableView)
        let padding: Int = 11
        let metrics: [String : AnyObject] = ["padding" : padding] // NSDictionaryOfVariableBindings(padding)
        let addConstraint = {(superview: UIView, format: String, views: [String : AnyObject]) -> Void in
                superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: [], metrics: metrics, views: views))
            }
        let rows: [String : AnyObject] = ["urlTextField":urlTextField, "searchedTextField":searchedTextField, "maxResultsTextField":maxResultsTextField, "maxDeepTextField":maxDeepTextField, "maxFlowTextField":maxFlowTextField, "goButton":goButton, "pauseButton":pauseButton, "resumeButton":resumeButton, "stopButton":stopButton, "infoLabel":infoLabel, "tableView":tableView]
        // NSDictionaryOfVariableBindings(urlTextField, searchedTextField, maxResultsTextField, maxDeepTextField, maxFlowTextField, goButton, pauseButton, resumeButton, stopButton, infoLabel, tableView)
        addConstraint(self.view!, "H:|-padding-[urlTextField]-padding-|", rows)
        addConstraint(self.view!, "H:|-padding-[searchedTextField(>=115)]-5-[maxResultsTextField]-5-[maxDeepTextField(==maxResultsTextField)]-5-[maxFlowTextField(==maxResultsTextField)]-padding-|", rows)
        addConstraint(self.view!, "H:|-padding-[goButton(>=stopButton)]-5-[pauseButton(==stopButton)]-5-[resumeButton(==stopButton)]-5-[stopButton]-padding-|", rows)
        addConstraint(self.view!, "H:|-padding-[infoLabel]-padding-|", rows)
        addConstraint(self.view!, "H:|-padding-[tableView]-padding-|", rows)
        addConstraint(self.view!, "V:|-30-[urlTextField(30)]-padding-[searchedTextField(30)]-padding-[goButton(30)]-padding-[infoLabel(30)]-padding-[tableView]-padding-|", rows)
        addConstraint(self.view!, "V:|-30-[urlTextField(30)]-padding-[maxResultsTextField(30)]-padding-[pauseButton(30)]-padding-[infoLabel(30)]-padding-[tableView]-padding-|", rows)
        addConstraint(self.view!, "V:|-30-[urlTextField(30)]-padding-[maxDeepTextField(30)]-padding-[resumeButton(30)]-padding-[infoLabel(30)]-padding-[tableView]-padding-|", rows)
        addConstraint(self.view!, "V:|-30-[urlTextField(30)]-padding-[maxFlowTextField(30)]-padding-[stopButton(30)]-padding-[infoLabel(30)]-padding-[tableView]-padding-|", rows)
        self.buttonSet()
    }



    func buttonSet() {
        switch model!.currentStatus {
            case .None, .Done, .Stopped:
                self.goButton.enabled = true
                self.pauseButton.enabled = false
                self.resumeButton.enabled = false
                self.stopButton.enabled = false
            case .InWork:
                self.goButton.enabled = false
                self.pauseButton.enabled = true
                self.resumeButton.enabled = false
                self.stopButton.enabled = true
            case .Suspended:
                self.goButton.enabled = false
                self.pauseButton.enabled = false
                self.resumeButton.enabled = true
                self.stopButton.enabled = false
        }

    }

    func tapView() {
        for i in 1001 ..< 1006 {
            let textField: UITextField = (self.view!.viewWithTag(i) as! UITextField)
            textField.resignFirstResponder()
        }
    }

    func reconnectView(view: UIView) {
        view.removeFromSuperview()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view!.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func testTextField() {
        for i in 1001 ..< 1006 {
            let textField: UITextField = (self.view!.viewWithTag(i) as! UITextField)
            self.textFieldTestAndCorrect(textField)
            switch textField.tag {
                case 1001:
                    self.model!.searchSettings.urlStartString = textField.text!
                    textField.text = model!.searchSettings.urlStartString
                case 1002:
                    self.model!.searchSettings.searchedString = textField.text!
                    textField.text = model!.searchSettings.searchedString
                case 1003:
                    self.model!.searchSettings.maxResults = Int(textField.text!)!
                    textField.text = "\(model!.searchSettings.maxResults)"
                case 1004:
                    self.model!.searchSettings.maxDeep = Int(textField.text!)!
                    textField.text = "\(model!.searchSettings.maxDeep)"
                case 1005:
                    self.model!.searchSettings.maxFlow = Int(textField.text!)!
                    textField.text = "\(model!.searchSettings.maxFlow)"
                default:
                    break
            }
        }
    }
    
    func strInt(str: String) -> Int {
        guard let num = Int(str)
            where num >= 0 else {
                return 0
        }
        return num
    }
    
    func textFieldTestAndCorrect(textField: UITextField) {
        var text: String = textField.text!
        text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

        let num:Int = strInt(text)
        if text.characters.count == 0 || (num == 0 && textField.tag > 1002) {
            switch textField.tag {
                case 1001:
                    textField.text = "http://msv-main.blogspot.com"
                case 1002:
                    textField.text = "iOS"
                case 1003:
                    textField.text = "100"
                case 1004:
                    textField.text = "3"
                case 1005:
                    textField.text = "3"
                default:
                    break
            }
        }
        else {
            if textField.tag == 1001 {
                if !text.containsString("http://") && !text.containsString("https://") {
                    text = "http://".stringByAppendingString(text)
                }
                if !text.containsString(".") {
                    text = text.stringByAppendingString(".com")
                }
            }
        }

    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        self.textFieldTestAndCorrect(textField)
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag: Int = textField.tag
        if tag == 1005 {
            go()
            return true
        }
        let textFieldNext: UITextField? = (self.view!.viewWithTag(tag + 1) as! UITextField)
        if textFieldNext != nil {
            textField.resignFirstResponder()
            textFieldNext!.becomeFirstResponder()
        }
        self.textFieldTestAndCorrect(textField)
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model!.items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType: String = "cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellType)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellType)
        }
        let item: MSVSimpleWebCrawlerSpiderItem = MSVSimpleWebCrawlerSpiderModel.sharedModel().items[indexPath.row] as! MSVSimpleWebCrawlerSpiderItem
        cell!.textLabel!.text = ""
        if item.numberResult > 0 || item.statusError != "" {
            cell!.textLabel!.text = "\(item.numberResult) times \(item.statusError != "" ? ", Error:\(item.statusError)" : "")"
        }
        else {
            if item.status == .Wait && item.level <= MSVSimpleWebCrawlerSpiderModel.sharedModel().searchSettings.maxDeep {
                cell!.textLabel!.text = "wait... \(item.level)"
            }
            if item.status == .InWork {
                cell!.textLabel!.text = "loading..."
            }
        }
        cell!.detailTextLabel!.text = item.urlString
        cell!.accessoryType = .DisclosureIndicator
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item: MSVSimpleWebCrawlerSpiderItem = MSVSimpleWebCrawlerSpiderModel.sharedModel().items[indexPath.row] 
        let urlString: String = item.urlString
        let url: NSURL = NSURL(string: urlString)!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object as! NSObject) == model && (keyPath == "currentStatus") {
            self.buttonSet()
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    func newItem() {
        self.showInfo()
        self.tableView.reloadData()
    }

    func downloadedItem() {
        self.showInfo()
        self.tableView.reloadData()
    }

    func showInfo() {
        self.infoLabel.text = "\(model!.currentInfo.flowCount) active flow, \(model!.currentInfo.viewCount) pages view, \(model!.currentInfo.foundCount) found"
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(tableView) {
            // Don't let selections of auto-complete entries fire the
            // gesture recognizer
            return false
        }
        return true
    }
}

