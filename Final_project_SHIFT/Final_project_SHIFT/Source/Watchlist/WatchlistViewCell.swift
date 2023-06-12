//
//  WatchlistViewCell.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 11.06.2023.
//
import SDWebImage
import UIKit

struct WatchlistCellModel {
    let name: String
    let currency: String
    let ticker: String
    let logo: String
    var price: Double // Обновлено: Цена акции теперь изменяемая
}

final class WatchlistViewCell: UICollectionViewCell {
    
    private lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        imageView.backgroundColor = Resources.Colors.gray
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    private lazy var tickerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .black)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.contentView.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        self.contentView.addSubview(tickerLabel)
        tickerLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoImage).inset(47)
            make.bottom.equalTo(logoImage.snp.centerY).inset(12)
        }
        
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(tickerLabel)
            make.top.equalTo(tickerLabel).inset(24)
            make.width.equalToSuperview().offset(-80)
            
        }
        
        self.contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func configure() {
        self.contentView.layer.cornerRadius = 15
        self.contentView.backgroundColor = .systemGray.withAlphaComponent(0.3)
        self.contentView.layer.borderWidth = 2
        updateBorderColor()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColor()
    }
    
    private func updateBorderColor() {
        self.contentView.layer.borderColor = currentThemeIsDark() ? UIColor.white.cgColor : UIColor.black.cgColor
    }
    
    private func currentThemeIsDark() -> Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
    
    func setModel(with model: WatchlistModel) {
        nameLabel.text = model.name
        tickerLabel.text = model.ticker
        priceLabel.text = "\(model.price) \(model.currency.getCurrencySymbol())"
    }
}
