//  WatchlistView.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import UIKit

protocol WatchlistViewProtocol: AnyObject {
    var collectionView: UICollectionView { get }
    func setupControllers(with tabBarController: UITabBarController, with navigationController: UINavigationController)
}

final class WatchlistView: UIView {
    
    // MARK: - Properties
    private weak var tabBarController: UITabBarController?
    private weak var navigationController: UINavigationController?
        
    private enum Metrics {
        static let titleLabelTopInset: CGFloat = 60
        static let titleLabelHorizontal: CGFloat = 16
        static let stackViewSpacing: CGFloat = 8.0
        static let collectionViewMinimumLineSpacing: CGFloat = 15.0
        static let collectionViewCornerRadius: CGFloat = 15.0
        static let blurEffectAlpha: CGFloat = 1
        static let activityIndicatorSize: CGFloat = 50.0
        static let favoriteStocksLabelLeadingInset: CGFloat = 16.0
        static let exchangeStatusViewTopOffset: CGFloat = 16.0
        static let collectionViewWidthMultiplier: CGFloat = 0.9
        static let collectionViewHeight: CGFloat = 80
        static let favoriteStocksLabelTopOffset: CGFloat = 16.0
        static let collectionViewTopOffset: CGFloat = 8
    }
    
    // MARK: - Subviews
    private var blurEffectView: UIVisualEffectView?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Resources.Strings.WatchlistScreen.titleLabel
        label.textAlignment = .center
        label.font = Resources.Fonts.thickFont
        label.textColor = Resources.Colors.green
        return label
    }()
    
    private lazy var exchangeStatusView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Metrics.stackViewSpacing

        let label = UILabel()

        if (FinhubExchangeManager.exchangeName != nil) {
            let exchangeName = FinhubExchangeManager.exchangeName ?? "Unknown Exchange"
            label.text = "\(exchangeName) \(Resources.Strings.WatchlistScreen.exchangeStatusViewOpenText)"
            label.textColor = Resources.Colors.gray

            let sunImage = UIImageView(image: UIImage(systemName: Resources.Strings.WatchlistScreen.exchangeStatusViewOpenImage))
            sunImage.tintColor = Resources.Colors.Watchlist.sunImageColor

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(sunImage)
        } else {
            label.text = Resources.Strings.WatchlistScreen.exchangeStatusViewCloseText
            label.textColor = Resources.Colors.gray

            let moonImage = UIImageView(image: UIImage(systemName: Resources.Strings.WatchlistScreen.exchangeStatusViewCloseImage))
            moonImage.tintColor = Resources.Colors.Watchlist.moonImageColor

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(moonImage)
        }

        return stackView
    }()

    private lazy var favoriteStocksLabel: UILabel = {
        let label = UILabel()
        label.text = Resources.Strings.WatchlistScreen.favoriteStocksLabelText
        label.font = Resources.Fonts.thickFont
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Metrics.collectionViewMinimumLineSpacing
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * Metrics.collectionViewWidthMultiplier, height: Metrics.collectionViewHeight)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(WatchlistViewCell.self, forCellWithReuseIdentifier: Resources.Strings.WatchlistScreen.watchlistCellIdentifier)
        collectionView.layer.cornerRadius = Metrics.collectionViewCornerRadius
        return collectionView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Resources.Colors.activityIndicatorColor
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
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
}

// MARK: - Public Method
extension WatchlistView {
    func createBlurEffect(isOn: Bool) {
        if isOn {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = collectionView.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView?.alpha = Metrics.blurEffectAlpha
            collectionView.addSubview(blurEffectView!)
        } else {
            blurEffectView?.removeFromSuperview()
            blurEffectView = nil
        }
    }
}

//MARK: - WatchlistViewProtocol
extension WatchlistView: WatchlistViewProtocol {
    func setupControllers(with tabBarController: UITabBarController, with navigationController: UINavigationController) {
        self.tabBarController = tabBarController
        self.navigationController = navigationController
        //tabBar
        tabBarController.tabBar.unselectedItemTintColor = Resources.Colors.TabBar.unselectedItemColor
        tabBarController.tabBar.tintColor = Resources.Colors.TabBar.selectedItemColor
    }
}
// MARK: - Layout
private extension WatchlistView {
    func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Metrics.titleLabelTopInset)
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).inset(Metrics.titleLabelHorizontal)
            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing).inset(Metrics.titleLabelHorizontal)
        }
        
        self.addSubview(exchangeStatusView)
        exchangeStatusView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Metrics.exchangeStatusViewTopOffset)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(favoriteStocksLabel)
        favoriteStocksLabel.snp.makeConstraints { make in
            make.top.equalTo(exchangeStatusView.snp.bottom).offset(Metrics.favoriteStocksLabelTopOffset)
            make.leading.equalToSuperview().inset(Metrics.favoriteStocksLabelLeadingInset)
        }
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(favoriteStocksLabel.snp.bottom).offset(Metrics.collectionViewTopOffset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(Metrics.activityIndicatorSize)
        }
    }
}

// MARK: - Configure
private extension WatchlistView {
    func configureView() {
        self.backgroundColor = Resources.Colors.backgroundColor
    }
}
