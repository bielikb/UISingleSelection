//
//  ViewController.swift
//  SampleApp
//
//  Created by Boris Bielik on 11/03/2019.
//  Copyright © 2019 Appsode, s.r.o. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    let cellIdentifier = "Identifier"
    var datasource: [Bool] = [true, true, false, false, false, false]

    override func viewDidLoad() {
        tableView.register(LabelWithSelectionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.reloadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LabelWithSelectionTableViewCell else {
            return UITableViewCell()
        }

        cell.isSelectionSelected = datasource[indexPath.row]
        cell.onSelectionButtonTap = { [weak self] button, isSelected -> Bool in
            let isAllowed = indexPath.row != 2
            self?.datasource[indexPath.row] = isSelected

            if !isAllowed {
                DispatchQueue.main.async {
                    cell.isSelectionSelected = false
                    cell.shake()
                }

            }
            return isAllowed
        }

        return cell
    }
}

extension ViewController: UITableViewDelegate {

}

