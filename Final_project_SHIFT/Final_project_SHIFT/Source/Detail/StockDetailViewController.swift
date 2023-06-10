//
//  DetailViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SnapKit
import SwiftUI
import UIKit

class ActivityIndicatorView: UIView {
    private var activityIndicator: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
//        backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        alpha = 0.8
//        layer.cornerRadius = 8.0

        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor.gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}

class StockDetailViewController: UIViewController {
    
    private var activityIndicator: UIActivityIndicatorView!
    let networkManager = NetworkService()
    var stockDetailModel: StockDetailModel!
    let stockSymbol: String
    private var backButton: UIBarButtonItem!
    var isFavorite = false
    
    init(symbol: String) {
        self.stockSymbol = symbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = stockSymbol
        
        createActivityIndicator()
        createBackButton()
        updateFavoriteButtonImage()
        
        let activityView = ActivityIndicatorView()
        activityView.center = view.center
        view.addSubview(activityView)
        activityView.startAnimating()
        //self.activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            
            DispatchQueue.main.async {
                self.networkManager.fetchStockProfile(symbol: self.stockSymbol) { result in
                    switch result {
                    case .success(let stockProfile):
                        self.networkManager.fetchStockCandles(symbol: self.stockSymbol, timeFrame: .weekend) { result in
                            switch result {
                            case .success(let fetchedCandles):
                                self.stockDetailModel = StockDetailModel(symbol: self.stockSymbol, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles)
                                
                                let swiftUIView = StockDetailView(selectedResolution: self.stockDetailModel.currentRange.getTag(), data: Candles.getCandles(candles: self.stockDetailModel.candles), stock: self.stockDetailModel)
                                
                                let swiftUIController = UIHostingController(rootView: swiftUIView)
                                self.addChild(swiftUIController)
                                self.view.addSubview(swiftUIController.view)
                                swiftUIController.view.translatesAutoresizingMaskIntoConstraints = false
                                
                                NSLayoutConstraint.activate([
                                    swiftUIController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                    swiftUIController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                    swiftUIController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                                    swiftUIController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                                ])
                                
                                //self.activityIndicator.stopAnimating()
                                activityView.stopAnimating()
                                swiftUIController.didMove(toParent: self)
                                
                            case .failure(let error):
                                print("Error fetching candles: \(error)")
                                //self?.createAlertController(title: "Error", message: "Failed to get company candles data")
                            }
                        }
                        
                    case .failure(let error):
                        print("Error: \(error)")
                        //self?.createAlertController(title: "Error", message: "Failed to get company profile data")
                    }
                }
            }
            
        }
            
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBackButtonImage()
        updateFavoriteButtonImage()
    }
    
    private func createActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
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



