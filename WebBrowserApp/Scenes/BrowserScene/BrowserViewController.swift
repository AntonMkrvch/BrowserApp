//
//  BrowserViewController.swift
//  WebBrowserApp
//
//  Created by Anton Makarevich on 6.05.23.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

class BrowserViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var historyButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    // MARK: - Stored properties
    
    var viewModel: BrowserViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setupBindings()
    }
    
    // MARK: - Private funcs
    
    private func setupBindings() {
        viewModel
            .urlValue
            .compactMap { $0 }
            .map { $0.absoluteString }
            .bind(to: addressTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .urlValue
            .do(onNext: { [weak self] _ in
                self?.addressTextField.resignFirstResponder()
            })
            .subscribe(onNext: { [weak self] url in
                guard let self else { return }
                self.webView.load(URLRequest(url: url))
            })
            .disposed(by: disposeBag)
        
        addressTextField.rx.controlEvent(.editingDidEndOnExit)
                .withLatestFrom(addressTextField.rx.text.asObservable())
                .compactMap { $0 }
                .bind(to: viewModel.manualRequestAddress)
                .disposed(by: disposeBag)
        
        historyButton.rx.tap
            .bind(to: viewModel.openHistory)
            .disposed(by: disposeBag)
        
        repeatButton.rx.tap
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        webView.rx.didFinishLoad
            .map { _ in self.webView.url }
            .compactMap { $0 }
            .bind(to: viewModel.pageLoaded )
            .disposed(by: disposeBag)
            
    }
    
   
}


extension BrowserViewController {
   
    // MARK: - Storyboard initialyze

    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func initFromStoryboard(name: String = "Main") -> Self {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}


