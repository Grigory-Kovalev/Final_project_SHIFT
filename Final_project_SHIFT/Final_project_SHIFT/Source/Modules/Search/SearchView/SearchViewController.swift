//
//  SearchViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//


import UIKit

protocol SearchViewControllerProtocol: AnyObject {
    var navigationController: UINavigationController? { get }
    
    func hideActivityIndicator()
    func setUIInteractionEnabled(_ enabled: Bool)
    func getCollectionView() -> UICollectionView
    func createBlurEffect(isOn: Bool)
    func showActivityIndicator()
    func showError(title: String, message: String)
}

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private let customView = SearchView()
    var presenter: SearchPresenterProtocol?
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customView.viewDidLoad(navigationController: self.navigationController!)
        customView.collectionView.delegate = self
        customView.collectionView.dataSource = self
        customView.searchBar.delegate = self
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        customView.createBlurEffect(isOn: false)
        //Запускаем индикатор
        customView.activityIndicator.stopAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(true)
    }
    
    // MARK: - Private Method
    private func createAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: Resources.Strings.SearchScreen.alertSubmitTitle, style: .default, handler: nil)
        alertController.addAction(submitAction)
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Убираем пробелы из запроса
        let trimmedText = customView.searchBar.text?.trimmingCharacters(in: .whitespaces)
        customView.searchBar.text = trimmedText
        
        // Скрыть клавиатуру
        searchBar.resignFirstResponder()

        // Запускаем активити индикатор
        showActivityIndicator()

        // Запрещаем пользовательское взаимодействие
        setUIInteractionEnabled(false)

        // Отображаем блюр эффект
        createBlurEffect(isOn: true)
        
        let ticker = searchBar.text ?? ""
        
        presenter?.searchButtonClicked(with: ticker)
        
    }
}

//MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Вернуть количество элементов в коллекции
        return self.presenter?.searchResultsCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = customView.collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Strings.SearchScreen.watchlistCellIdentifier, for: indexPath) as! SearchViewCell
        let searchData = self.presenter?.searchResultsItem(by: indexPath.item)
        cell.setModel(with: searchData!)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        customView.createBlurEffect(isOn: true)
        //Запускаем индикатор
        customView.activityIndicator.startAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(false)
                
        self.presenter?.didSelectStock(at: indexPath.row)
    }
}

//MARK: - SearchViewControllerProtocol
extension SearchViewController: SearchViewControllerProtocol {
    func setUIInteractionEnabled(_ enabled: Bool) {
        customView.searchBar.isUserInteractionEnabled = enabled
        customView.collectionView.isUserInteractionEnabled = enabled
        tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
    
    func showActivityIndicator() {
        customView.activityIndicator.startAnimating()
    }
    
    func createBlurEffect(isOn: Bool) {
        self.customView.createBlurEffect(isOn: isOn)
    }
    
    func showError(title: String, message: String) {
        self.createAlertController(title: title, message: message)
    }
    
    func getCollectionView() -> UICollectionView {
        return self.customView.collectionView
    }
    
    func hideActivityIndicator() {
        customView.activityIndicator.stopAnimating()
    }
}
