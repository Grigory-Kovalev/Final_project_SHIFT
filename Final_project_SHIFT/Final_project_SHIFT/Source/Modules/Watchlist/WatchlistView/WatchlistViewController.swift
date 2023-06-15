//
//  WatchlistViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

protocol WatchlistViewControllerProtocol: AnyObject {
    func reloadCollectionView()
    func showActivityIndicator()
    func hideActivityIndicator()
    func showError(message: String)
    func createBlurEffect(isOn: Bool)
    func setUIInteractionEnabled(_ enabled: Bool)
    func getCollectionView() -> UICollectionView
    var navigationController: UINavigationController? { get }
}

class WatchlistViewController: UIViewController {
    
    // MARK: - Properties
    private let customView = WatchlistView()
    var presenter: WatchlistPresenterProtocol?
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customView.setupControllers(with: self.tabBarController!, with: self.navigationController!)
        customView.collectionView.dataSource = self
        customView.collectionView.delegate = self
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideActivityIndicator()
        self.createBlurEffect(isOn: false)
        self.setUIInteractionEnabled(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.viewDidDisappear()
    }
}

//MARK: - UICollectionViewDataSource
extension WatchlistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfStocks ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Strings.WatchlistScreen.watchlistCellIdentifier, for: indexPath) as! WatchlistViewCell
        let searchData = presenter?.getStock(at: indexPath.item)
        cell.setModel(with: WatchlistModel(ticker: searchData?.ticker ?? "", name: searchData?.name ?? "", logo: searchData?.logo ?? "", price: searchData?.price ?? 0, currency: searchData?.currency ?? ""))
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension WatchlistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectStock(at: indexPath.item)
    }
}

//MARK: - WatchlistViewControllerProtocol
extension WatchlistViewController: WatchlistViewControllerProtocol {
    func reloadCollectionView() {
        customView.collectionView.reloadData()
    }
    
    func showActivityIndicator() {
        customView.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        customView.activityIndicator.stopAnimating()
    }
    
    func createBlurEffect(isOn: Bool) {
        customView.createBlurEffect(isOn: isOn)
    }
    
    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getCollectionView() -> UICollectionView {
        return self.customView.collectionView
    }
    
    func setUIInteractionEnabled(_ enabled: Bool) {
        customView.collectionView.isUserInteractionEnabled = enabled
        self.tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
}
