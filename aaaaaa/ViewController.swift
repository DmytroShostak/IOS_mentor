//
//  ViewController.swift
//  aaaaaa
//
//  Created by Wafy CI on 27.04.2020.
//  Copyright © 2020 selfed. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var banks = [Bank]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleJSON()
    }
    
    func handleJSON() {
        let url = URL(string: "https://resources.finance.ua/ua/public/currency-cash.json")!
        URLSession.shared.dataTask(with: url) { data, _, error in
            if  let data = data,
                let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any],
                let organizations = jsonDictionary["organizations"] as? [[AnyHashable:Any]]
            {
                for org in organizations {
                    let n = org["title"] as! String
                    var currs = [CurrencyPrice]()
                    let currenciesDictionary = org["currencies"] as! [AnyHashable:Any]
                    currenciesDictionary.forEach { (arg) in
                        let (key, v) = arg
                        let value = v as! [AnyHashable:Any]
                        let ask = value["ask"] as! String
                        let bid = value["bid"] as! String
                        currs.append(CurrencyPrice(key as! String, ask: ask, bid: bid))
                    }
                    self.banks.append(Bank(n, currs))
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                fatalError(String(describing: error))
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return banks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks[section].currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bank = banks[indexPath.section]
        let currency = bank.currencies[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        cell.label.text = "\(currency.name)\nAsk: \(currency.ask)\nBid: \(currency.bid)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width, height: 60))
        header.text = banks[section].orgName
        return header
    }
    
}

struct Bank {
    let orgName: String
    let currencies: [CurrencyPrice]
    init(_ n: String, _ c: [CurrencyPrice]) {
        orgName = n
        currencies = c
    }
}

struct CurrencyPrice {
    let name: String
    let ask: String
    let bid: String
    init(_ n: String, ask: String, bid: String) {
        name = n
        self.ask = ask
        self.bid = bid
    }
}

class Cell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

