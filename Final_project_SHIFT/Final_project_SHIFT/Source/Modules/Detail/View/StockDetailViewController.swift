//
//  DetailViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SnapKit
import SwiftUI
import UIKit

protocol StockDetailVCProtocol: AnyObject {
    
}

class StockDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let stockDetailModel: StockDetailModel
    private var backButton: UIBarButtonItem!
    var isFavorite: Bool?
    
    var presenter: StockDetailPresenterProtocol?
    
    let persistentStorageService = PersistentStorageService()
    
    // MARK: - Init
    init(stockDetailModel: StockDetailModel) {
        self.stockDetailModel = stockDetailModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurView()
        self.swiftUIhosting()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBackButtonImage()
        updateFavoriteButtonImage()
    }
}

// MARK: - swiftUIhosting
private extension StockDetailViewController {
    func swiftUIhosting() {
        let swiftUIView = StockDetailView(selectedResolution: stockDetailModel.currentRange.getTag(), data: Candles.getCandles(candles: stockDetailModel.candles), stock: stockDetailModel)
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hostingController.didMove(toParent: self)
    }
}

// MARK: - configurView
private extension StockDetailViewController {
    func configurView() {
        isFavorite = persistentStorageService.isStockFavorite(ticker: stockDetailModel.symbol)
        
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title = stockDetailModel.symbol
        
        createBackButton()
        
        updateFavoriteButtonImage()
        
        let favoriteButton = isFavorite ?? false ? UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal) : UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColorForFavoriteButton())
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favoriteButton, style: .plain, target: self, action: #selector(favoriteButtonTapped))
        
    }
}

// MARK: - Private Methods
private extension StockDetailViewController {
    
    // MARK: - Back Button
    func createBackButton() {
        backButton = UIBarButtonItem(image: backButtonImage(), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    func updateBackButtonImage() {
        backButton.image = backButtonImage()
    }
    
    func backButtonImage() -> UIImage? {
        return currentThemeIsDark() ? Resources.Images.darkModeImage : Resources.Images.lightModeImage
    }
    
    // MARK: - Favorite Button
    
    func tintColorForFavoriteButton() -> UIColor {
        return currentThemeIsDark() ? .white : .black
    }
    
    func updateFavoriteButtonImage() {
        let favoriteButtonImage = isFavorite ?? false ? UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal) : UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColorForFavoriteButton())
        navigationItem.rightBarButtonItem?.image = favoriteButtonImage
    }
    
    // MARK: - Theme Handling
    
    func currentThemeIsDark() -> Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
    
    // MARK: - Button Actions
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func favoriteButtonTapped() {
        isFavorite?.toggle()
        updateFavoriteButtonImage()
        
        if isFavorite ?? false {
            persistentStorageService.saveStockToCoreData(ticker: stockDetailModel.symbol, name: stockDetailModel.companyName, logo: stockDetailModel.stockProfile.logo, currency: stockDetailModel.stockProfile.currency, price: stockDetailModel.candles.c.last ?? 0, isFavorite: true)
        } else {
            persistentStorageService.deleteStockBy(ticker: stockDetailModel.symbol)
        }
    }
}

extension StockDetailViewController: StockDetailVCProtocol {
    
}
