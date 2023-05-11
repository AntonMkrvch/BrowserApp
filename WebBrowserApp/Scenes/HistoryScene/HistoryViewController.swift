//
//  HistoryViewController.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 8.05.23.
//

import UIKit
import RxSwift

class HistoryViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var historyTableView: UITableView!
    
    // MARK - Stored properties
    
    var viewModel: HistoryViewModel!
    private let disposeBag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        viewModel.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.reloadItems
            .subscribe(onNext: { [weak self] in self?.historyTableView.reloadData() })
            .disposed(by: disposeBag)
        
        searchTextField.rx.text.changed
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(to: viewModel.cancel)
            .disposed(by: disposeBag)
        
        historyTableView.rx.itemSelected
            .map { [weak self] in
                self!.viewModel.historyItems[$0.item] }
            .bind(to: viewModel.selectItem)
            .disposed(by: disposeBag)
    }

}


extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.historyItems[indexPath.item]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = model.address.absoluteString
        return cell
    }
    
}

extension HistoryViewController {
   
    // MARK: - Storyboard initialyze

    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func initFromStoryboard(name: String = "Main") -> Self {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}
