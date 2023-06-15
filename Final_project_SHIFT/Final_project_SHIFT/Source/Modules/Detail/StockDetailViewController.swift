//
//  DetailViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SnapKit
import SwiftUI
import UIKit

class StockDetailViewController: UIViewController {
    
    private let stockDetailModel: StockDetailModel
    private var backButton: UIBarButtonItem!
    var isFavorite: Bool?
    
    let persistentStorageService = PersistentStorageService()
    
    init(stockDetailModel: StockDetailModel) {
        self.stockDetailModel = stockDetailModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFavorite = persistentStorageService.isStockFavorite(ticker: stockDetailModel.symbol)
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title = stockDetailModel.symbol
        
        createBackButton()
        
        updateFavoriteButtonImage()
        
        let favoriteButton = isFavorite ?? false ? UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal) : UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColorForFavoriteButton())
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favoriteButton, style: .plain, target: self, action: #selector(favoriteButtonTapped))
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if stockDetailModel.candles.c.last != persistentStorageService.getLastPriceFrom(ticker: stockDetailModel.symbol) {
            persistentStorageService.deleteStockBy(ticker: stockDetailModel.symbol)
            persistentStorageService.saveStockToCoreData(ticker: stockDetailModel.symbol, name: stockDetailModel.companyName, logo: stockDetailModel.stockProfile.logo, currency: stockDetailModel.stockProfile.currency, price: stockDetailModel.candles.c.last ?? 0, isFavorite: true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBackButtonImage()
        updateFavoriteButtonImage()
    }
    
    // MARK: - Back Button
    
    private func createBackButton() {
        backButton = UIBarButtonItem(image: backButtonImage(), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func updateBackButtonImage() {
        backButton.image = backButtonImage()
    }
    
    private func backButtonImage() -> UIImage? {
        return currentThemeIsDark() ? Resources.Images.darkModeImage : Resources.Images.lightModeImage
    }
    
    // MARK: - Favorite Button
    
    private func tintColorForFavoriteButton() -> UIColor {
        return currentThemeIsDark() ? .white : .black
    }
    
    private func createFavoriteButton() {
        
    }
    
    // MARK: - Theme Handling
    
    private func currentThemeIsDark() -> Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func favoriteButtonTapped() {
        isFavorite?.toggle()
        updateFavoriteButtonImage()
        
        if isFavorite ?? false {
            
            persistentStorageService.saveStockToCoreData(ticker: stockDetailModel.symbol, name: stockDetailModel.companyName, logo: stockDetailModel.stockProfile.logo, currency: stockDetailModel.stockProfile.currency, price: stockDetailModel.candles.c.last ?? 0, isFavorite: true)

        } else {
            persistentStorageService.deleteStockBy(ticker: stockDetailModel.symbol)
        }
    }

    
    private func updateFavoriteButtonImage() {
        let favoriteButtonImage = isFavorite ?? false ? UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal) : UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColorForFavoriteButton())
        navigationItem.rightBarButtonItem?.image = favoriteButtonImage
    }
}



