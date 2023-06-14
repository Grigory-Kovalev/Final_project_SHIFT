//
//  SearchView.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import SnapKit
import UIKit

protocol SearchViewProtocol: AnyObject {
    var collectionView: UICollectionView { get }
    func setupControllers(with tabBarController: UITabBarController, with navigationController: UINavigationController)
}

final class SearchView: UIView {
    
    // MARK: - Properties
    private weak var tabBarController: UITabBarController?
    private weak var navigationController: UINavigationController?
    weak var vc: SearchViewControllerDelegate?
        
    private enum Metrics {
        static let collectionViewCornerRadius: CGFloat = 15.0
        static let collectionViewWidthMultiplier: CGFloat = 0.9
        static let collectionViewHeightMultiplier: CGFloat = 0.12
    }
    
    // MARK: - Subviews
    private var blurEffectView: UIVisualEffectView?
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Resources.Strings.SearchScreen.searchBarPlaceholder
        searchBar.showsCancelButton = false
        return searchBar
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Resources.Colors.activityIndicatorColor
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * Metrics.collectionViewWidthMultiplier, height: UIScreen.main.bounds.height * Metrics.collectionViewHeightMultiplier)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(SearchViewCell.self, forCellWithReuseIdentifier: Resources.Strings.SearchScreen.watchlistCellIdentifier)
        collectionView.layer.cornerRadius = Metrics.collectionViewCornerRadius
        return collectionView
    }()
    
    private lazy var cancelButton: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Resources.Strings.SearchScreen.cancelButtonTitle, style: .plain, target: self, action: #selector(cancelButtonTapped))
        toolbar.items = [flexibleSpace, cancelButton]
        searchBar.inputAccessoryView = toolbar
        return toolbar
    }()
    
    // MARK: - Initialization
    init() {
        super.init(frame: .zero)
        configureView()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func cancelButtonTapped() {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Public Method
extension SearchView {
    func createBlurEffect(isOn: Bool) {
        if isOn {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = collectionView.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.addSubview(blurEffectView!)
        } else {
            blurEffectView?.removeFromSuperview()
            blurEffectView = nil
        }
    }
}

//MARK: - SearchViewProtocol
extension SearchView: SearchViewProtocol {
    func setupControllers(with tabBarController: UITabBarController, with navigationController: UINavigationController) {
        self.tabBarController = tabBarController
        self.navigationController = navigationController
        //tabBar
        tabBarController.tabBar.unselectedItemTintColor = Resources.Colors.TabBar.unselectedItemColor
        tabBarController.tabBar.tintColor = Resources.Colors.TabBar.selectedItemColor
    }
}

// MARK: - Layout
private extension SearchView {
    func setupUI() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        self.addSubview(activityIndicator)
        self.searchBar.inputAccessoryView = cancelButton
    }
}

// MARK: - Configure
private extension SearchView {
    func configureView() {
        self.backgroundColor = Resources.Colors.backgroundColor
        
        tabBarController?.tabBar.unselectedItemTintColor = Resources.Colors.TabBar.unselectedItemColor
        tabBarController?.tabBar.tintColor = Resources.Colors.TabBar.selectedItemColor
        
        //Nav
        navigationController?.navigationItem.title = Resources.Strings.SearchScreen.navigationTitle
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Resources.Colors.green
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        //searchBar
        navigationController?.navigationItem.titleView = searchBar
        //верхний регистр для клавиатуры
        searchBar.autocapitalizationType = .allCharacters
    }
}
