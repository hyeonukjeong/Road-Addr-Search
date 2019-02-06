//
//  RoadTableViewController.swift
//  RoadAddress
//
//  Created by Jeong Hyeon Uk on 07/01/2019.
//  Copyright © 2019 Hyeonuk Jeong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RoadTableViewController: UITableViewController, UISearchBarDelegate {
    
    var address = [String]()
    var addressURL = "https://www.juso.go.kr/addrlink/addrLinkApi.do"
    var confmKey = "U01TX0FVVEgyMDE5MDEwNzAzMDA0MjEwODQyMTc="
    var currentPage = 1
    var countPerPage = "100"
    var keyword = "대구 대학로"
    var resultType = "json"
    
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func getRoadAddresses(url : String, parameters : [String : String]) {
        Alamofire.request(url, method : .get, parameters : parameters).responseJSON { response in
            if response.result.isSuccess {
                let addrJSON : JSON = JSON(response.result.value!)
                self.updateAddresses(json : addrJSON)
            }
            else {
                print("ERROR \(String(describing: response.result.error))")
            }
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func updateAddresses(json : JSON) {
        let updateJson = json ["results"]["juso"]
        for (_, jsonValue) in updateJson {
            let siNm = jsonValue ["siNm"]
            let sggNm = jsonValue ["sggNm"]
            let emdNm = jsonValue ["emdNm"]
            let region = jsonValue ["admCd"]
            let regionAddr = ("\(siNm) \(sggNm) \(emdNm)")
            let addrRoadCode = jsonValue ["rnMgtSn"]
            let addrRoad = jsonValue ["roadAddr"]
            let addr = ("\(addrRoad)\n\(regionAddr)\n\(region)\n\(addrRoadCode)")
            address.append(addr)
        }
    }
    
    override func viewDidLoad() {
        self.activityIndicator.startAnimating()
        self.addressSearchBar.delegate = self
        super.viewDidLoad()
        let params = [
            "confmKey" : confmKey,
            "currentPage" : String(currentPage),
            "countPerPage" : countPerPage,
            "keyword" : keyword,
            "resultType" : resultType
            ]
        getRoadAddresses(url: addressURL, parameters: params)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return address.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roadCell")
        cell?.textLabel?.text = address[indexPath.row]
        cell?.textLabel?.numberOfLines = 4
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = address.count - 1
        if indexPath.row == lastElement {
            currentPage += 1
            let params = [
                "confmKey" : confmKey,
                "currentPage" : String(currentPage),
                "countPerPage" : countPerPage,
                "keyword" : keyword,
                "resultType" : resultType
            ]
            getRoadAddresses(url: addressURL, parameters: params)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
        let currentItem = currentCell.textLabel!.text
        print(currentItem!)
    }
    
    func refresh() {
        print("refresh table!")
        self.address.removeAll()
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.addressSearchBar.text = ""
        self.addressSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.addressSearchBar.resignFirstResponder()
        refresh()
        print("search text : ", self.addressSearchBar.text!)
        keyword = self.addressSearchBar.text!
        let params = [
            "confmKey" : confmKey,
            "currentPage" : String(currentPage),
            "countPerPage" : countPerPage,
            "keyword" : keyword,
            "resultType" : resultType
        ]
        getRoadAddresses(url: addressURL, parameters: params)
    }
    
}
