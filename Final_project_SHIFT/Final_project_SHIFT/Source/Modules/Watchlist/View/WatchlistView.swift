//  WatchlistView.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import UIKit

protocol IWatchlistView: AnyObject {
    //var tapButtonHandler: (() -> Void)? { get set }

    func setupControllers(with tabBarController: UITabBarController, with navigationController: UINavigationController)
}

final class WatchlistView: UIView {
    
    private weak var tabBarController: UITabBarController?
    private weak var navigationController: UINavigationController?
        
    private enum Metrics {
        static let titleLabelTopInset: CGFloat = -18
        static let titleLabelHorizontal: CGFloat = 16
        static let stackViewSpacing: CGFloat = 8.0
        static let collectionViewMinimumLineSpacing: CGFloat = 15.0
        static let collectionViewCornerRadius: CGFloat = 15.0
        static let blurEffectAlpha: CGFloat = 1
        static let activityIndicatorSize: CGFloat = 50.0
        static let favoriteStocksLabelLeadingInset: CGFloat = 16.0
        static let exchangeStatusViewTopInset: CGFloat = -16.0
        static let collectionViewBottomInset: CGFloat = 16.0
        static let collectionViewWidthMultiplier: CGFloat = 0.9
        static let collectionViewHeightMultiplier: CGFloat = 0.1
        static let favoriteStocksLabelTopInset: CGFloat = -16
        static let collectionViewTopInset: CGFloat = -8
    }
    
    private var blurEffectView: UIVisualEffectView?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Resources.Strings.Watchlist.titleLabel
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

        if Resources.Condition.exchangeStatus {
            // Биржа открыта с понедельника по пятницу
            label.text = Resources.Strings.Watchlist.exchangeStatusViewOpenText
            label.textColor = Resources.Colors.gray

            let sunImage = UIImageView(image: UIImage(systemName: Resources.Strings.Watchlist.exchangeStatusViewOpenImage))
            sunImage.tintColor = Resources.Colors.Watchlist.sunImageColor

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(sunImage)
        } else {
            // Биржа закрыта или не рабочий день
            label.text = Resources.Strings.Watchlist.exchangeStatusViewCloseText
            label.textColor = Resources.Colors.gray

            let moonImage = UIImageView(image: UIImage(systemName: Resources.Strings.Watchlist.exchangeStatusViewCloseImage))
            moonImage.tintColor = Resources.Colors.Watchlist.moonImageColor

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(moonImage)
        }

        return stackView
    }()
    
    private lazy var favoriteStocksLabel: UILabel = {
        let label = UILabel()
        label.text = Resources.Strings.Watchlist.favoriteStocksLabelText
        label.font = Resources.Fonts.thickFont
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Metrics.collectionViewMinimumLineSpacing
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * Metrics.collectionViewWidthMultiplier, height: UIScreen.main.bounds.height * Metrics.collectionViewHeightMultiplier)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(WatchlistViewCell.self, forCellWithReuseIdentifier: Resources.Strings.Watchlist.watchlistCellIdentifier)
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
    
    //MARK: - Init
    init() {
        super.init(frame: .zero)
        configureView()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

//MARK: - Extensions
extension WatchlistView: IWatchlistView {
    func setupControllers(with tabBarController: UITabBarController, with navigationController: UINavigationController) {
        self.tabBarController = tabBarController
        self.navigationController = navigationController
        //tabBar
        tabBarController.tabBar.unselectedItemTintColor = Resources.Colors.TabBar.unselectedItemColor
        tabBarController.tabBar.tintColor = Resources.Colors.TabBar.selectedItemColor
        
        //Nav
        navigationController.navigationItem.title = Resources.Strings.Watchlist.titleLabel
    }
}

private extension WatchlistView {
    func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).inset(Metrics.titleLabelTopInset)
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).inset(Metrics.titleLabelHorizontal)
            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing).inset(Metrics.titleLabelHorizontal)
        }
        
        self.addSubview(exchangeStatusView)
        exchangeStatusView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(Metrics.exchangeStatusViewTopInset)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(favoriteStocksLabel)
        favoriteStocksLabel.snp.makeConstraints { make in
            make.top.equalTo(exchangeStatusView.snp.bottom).inset(Metrics.favoriteStocksLabelTopInset)
            make.leading.equalToSuperview().inset(Metrics.favoriteStocksLabelLeadingInset)
        }
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(favoriteStocksLabel.snp.bottom).inset(Metrics.collectionViewTopInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(Metrics.collectionViewBottomInset)
        }
        
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(Metrics.activityIndicatorSize)
        }
    }
}

private extension WatchlistView {
    func configureView() {
        self.backgroundColor = Resources.Colors.backgroundColor
    }
}
