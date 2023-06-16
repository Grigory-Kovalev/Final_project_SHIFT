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
    func popViewController()
}

class StockDetailViewController: UIViewController {
    
    // MARK: - Properties
    private var backButton: UIBarButtonItem!
    var isFavorite: Bool?
    
    var presenter: StockDetailPresenterProtocol?
        
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
        let model = self.presenter?.getStockDetailViewModel()
        guard let model else { return }
        let latestPrice = model.stock.candles.c.last ?? 0
        let swiftUIView = StockDetailView(selectedResolution: model.selectedResolution, data: model.data, stock: model.stock, latestPrice: latestPrice)
        
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
        isFavorite = self.presenter?.isFavoriteTicker()
        
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title = self.presenter?.getTicker()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Resources.Colors.green
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
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
        self.presenter?.backButtonTapped()
    }
    
    @objc func favoriteButtonTapped() {
        isFavorite?.toggle()
        updateFavoriteButtonImage()
        
        if isFavorite ?? false {
            self.presenter?.saveStock()
        } else {
            self.presenter?.deleteStock()
        }
    }
}

// MARK: - StockDetailVCProtocol
extension StockDetailViewController: StockDetailVCProtocol {
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }    
}
