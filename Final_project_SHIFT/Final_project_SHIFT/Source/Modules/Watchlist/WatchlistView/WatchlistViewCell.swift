//
//  WatchlistViewCell.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 11.06.2023.
//
import SDWebImage
import UIKit

protocol IWatchlistViewCell: AnyObject {
    func setModel(with model: WatchlistModel)
    func updatePriceLabel(by value: Double)
}

final class WatchlistViewCell: UICollectionViewCell {
    // MARK: - Properties
    private var previousPrice: Double?
    private var currencySymbol: String?
    
    private enum Metrics {
        static let logoImageCornerRadius: CGFloat = 10
        static let logoImageSideLength = 45
        static let logoImageLeadingInset = 8
        static let tickerLabelLeadingOffset = 8
        static let tickerLabelBottomInset = 12
        static let priceLabelTrailingInset = 16
        static let nameLabelLeadingInset = -8
        static let nameLabelTrailingInset = -8
        static let nameLabelTopInset = 27
        static let backgroundCornerRadius: CGFloat = 15
        static let backgroundBorderWidth: CGFloat = 2
    }
    
    // MARK: - Subviews
    private lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Metrics.logoImageCornerRadius
        imageView.frame = CGRect(x: 0, y: 0, width: Metrics.logoImageSideLength, height: Metrics.logoImageSideLength)
        imageView.backgroundColor = Resources.Colors.gray
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Resources.Fonts.nameLabelFont
        return label
    }()
    
    private lazy var tickerLabel: UILabel = {
        let label = UILabel()
        label.font = Resources.Fonts.tickerLabelFont
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = Resources.Fonts.priceLabelFont
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - light/вфкл theme tracking
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColor()
    }
    
    // MARK: - Private method
    private func currentThemeIsDark() -> Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}

// MARK: - IWatchlistViewCell
extension WatchlistViewCell: IWatchlistViewCell {
    func setModel(with model: WatchlistModel) {
        nameLabel.text = model.name
        tickerLabel.text = model.ticker
        priceLabel.text = "\(model.price) \(model.currency.getCurrencySymbol())"
        currencySymbol = model.currency.getCurrencySymbol()
        
        if let url = URL(string: model.logo) {
                logoImage.sd_setImage(with: url, placeholderImage: nil)
            }
    }
    
    func updatePriceLabel(by value: Double) {
        // Округляем значение цены до двух знаков после запятой
        let roundedPrice = String(format: "%.2f", value)

        // Формируем строку с добавлением символа валюты
        let formattedPrice = "\(roundedPrice) \(self.currencySymbol ?? "")"
        self.priceLabel.text = formattedPrice
        
        // Сравниваем текущую цену с предыдущей ценой и устанавливаем цвет текста
        if let previousPrice {
            let priceChange = value - previousPrice
            if priceChange > 0 {
                self.priceLabel.textColor = Resources.Colors.priceGreen
            } else if priceChange < 0 {
                self.priceLabel.textColor = Resources.Colors.priceRed
            } else {
                // Если цена не изменилась, можно использовать стандартный цвет
                self.priceLabel.textColor = Resources.Colors.labelColor
            }
        }
        // Сохраняем текущую цену как предыдущую для следующего обновления
        self.previousPrice = value
    }
}

// MARK: - Layout
private extension WatchlistViewCell {
    func setupUI() {
        self.contentView.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.logoImageLeadingInset)
            make.centerY.equalToSuperview()
            make.height.equalTo(Metrics.logoImageSideLength)
            make.width.equalTo(Metrics.logoImageSideLength)
        }

        self.contentView.addSubview(tickerLabel)
        tickerLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoImage.snp.trailing).offset(Metrics.tickerLabelLeadingOffset)
            make.top.equalTo(logoImage.snp.top)
        }

        self.contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Metrics.priceLabelTrailingInset)
        }
        
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoImage.snp.trailing).inset(Metrics.nameLabelLeadingInset)
            make.trailing.equalTo(priceLabel.snp.leading).inset(Metrics.nameLabelTrailingInset)
            make.top.equalTo(tickerLabel).inset(Metrics.nameLabelTopInset)
        }
    }
}

// MARK: - Configure
private extension WatchlistViewCell {
    func updateBorderColor() {
        self.contentView.layer.borderColor = currentThemeIsDark() ? UIColor.white.cgColor : UIColor.black.cgColor
    }
    
    func configure() {
        self.contentView.layer.cornerRadius = Metrics.backgroundCornerRadius
        self.contentView.backgroundColor = Resources.Colors.Watchlist.cellBackground
        self.contentView.layer.borderWidth = Metrics.backgroundBorderWidth
        updateBorderColor()
    }
}
