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
    
//    private let stockDetailModel: StockDetailModel
    let symbol: String
    private var backButton: UIBarButtonItem!
    var isFavorite = false
    
//    init(stockDetailModel: StockDetailModel) {
//        self.stockDetailModel = stockDetailModel
//        super.init(nibName: nil, bundle: nil)
//    }
    
    init(symbol: String) {
        self.symbol = symbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = symbol
        
        createBackButton()
        
        updateFavoriteButtonImage()
        
        let favoriteButton = isFavorite ? UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal) : UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColorForFavoriteButton())
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favoriteButton, style: .plain, target: self, action: #selector(favoriteButtonTapped))
        
//        let swiftUIView = StockDetailView(selectedResolution: stockDetailModel.currentRange.getTag(), data: Candles.getCandles(candles: stockDetailModel.candles), stock: stockDetailModel)
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
        self.isFavorite.toggle()
        updateFavoriteButtonImage()
    }
    
    private func updateFavoriteButtonImage() {
        let favoriteButtonImage = isFavorite ? UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal) : UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColorForFavoriteButton())
        navigationItem.rightBarButtonItem?.image = favoriteButtonImage
    }
}



