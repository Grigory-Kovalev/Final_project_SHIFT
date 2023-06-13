//
//  WatchlistView.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import UIKit

final class WatchlistView: UIView {
    
    private weak var tabBarController: UITabBarController?
    private weak var navigationController: UINavigationController?
    
    let reuseIdentifier = "CellIdentifier"
    
    private enum Metrics {
        static let topLabelOffset: CGFloat = 150
        static let bottomLabelOffset: CGFloat = -40
        static let hOffset: CGFloat = 10
        
        static let borderWidth: CGFloat = 1
        static let numberOfLines: Int = 1
    }
    
    private var blurEffectView: UIVisualEffectView?
    
    private lazy var exchangeStatusView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0

        let label = UILabel()
        let now = Date() // Получаем текущую дату и время
        var calendar = Calendar.current
        let newYorkTimeZone = TimeZone(identifier: "America/New_York")
        calendar.timeZone = newYorkTimeZone!

        let openHour = 9
        let openMinute = 30
        let closeHour = 16

        let weekday = calendar.component(.weekday, from: now)
        if weekday >= 2 && weekday <= 6, // Проверяем, что это понедельник-пятница
            let openTime = calendar.date(bySettingHour: openHour, minute: openMinute, second: 0, of: now),
            let closeTime = calendar.date(bySettingHour: closeHour, minute: 0, second: 0, of: now),
            calendar.isDate(now, inSameDayAs: openTime) || calendar.isDate(now, inSameDayAs: closeTime),
            now >= openTime && now <= closeTime {
            // Биржа открыта с понедельника по пятницу
            label.text = "Stock exchange is open"
            label.textColor = Resources.Colors.gray

            let sunImage = UIImageView(image: UIImage(systemName: "sun.max"))
            sunImage.tintColor = .yellow

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(sunImage)
        } else {
            // Биржа закрыта или не рабочий день
            label.text = "Stock exchange is closed"
            label.textColor = Resources.Colors.gray

            let moonImage = UIImageView(image: UIImage(systemName: "moon.zzz"))
            moonImage.tintColor = .blue

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(moonImage)
        }

        return stackView
    }()
    
    private lazy var favoriteStocksLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorite stocks"
        label.font = UIFont.systemFont(ofSize: 22, weight: .black)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(WatchlistViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.layer.cornerRadius = 15
        return collectionView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
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
    
    func setupControllers(with tabBarController: UITabBarController, with navigationController: UINavigationController) {
        self.tabBarController = tabBarController
        self.navigationController = navigationController
    }
    
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

//MARK: - Extensions
//extension WatchlistView: IView
//{
//    func set(text: String) {
//        self.label.text = text
//    }
//}

private extension WatchlistView {
    func setupUI() {
        self.addSubview(exchangeStatusView)
        exchangeStatusView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(8)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(favoriteStocksLabel)
        favoriteStocksLabel.snp.makeConstraints { make in
            make.top.equalTo(exchangeStatusView.snp.bottom).inset(-16)
            make.leading.equalToSuperview().inset(16)
        }
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(favoriteStocksLabel.snp.bottom).inset(-8)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.addSubview(activityIndicator)
    }
}

private extension WatchlistView {
    func configureView() {
        self.backgroundColor = .systemBackground
        
        //tabBar
        self.tabBarController?.tabBar.unselectedItemTintColor = .systemGray
        self.tabBarController?.tabBar.tintColor = .label
        
        //Nav
        self.navigationController?.navigationItem.title = "Watchlist"
        let attributes: [NSAttributedString.Key: Any] = [
            //.font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: Resources.Colors.green
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
    }
}

