//
//  SearchViewCell.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SnapKit
import UIKit

final class SearchViewCell: UICollectionViewCell {
    
    private lazy var indexImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .black)
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
        
        self.contentView.addSubview(indexImage)
        indexImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        self.contentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.leading.equalTo(indexImage).inset(47)
            make.bottom.equalTo(indexImage.snp.centerY).inset(12)
        }
        
        self.contentView.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(symbolLabel)
            make.top.equalTo(symbolLabel).inset(24)
            make.width.equalToSuperview().offset(-80)
            
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
    
    func setModel(with model: SearchCellModel) {
        fullNameLabel.text = model.fullName
        symbolLabel.text = model.symbol
        
        indexImage.image = UIImage(systemName: "\(model.index.description).circle.fill")?.withTintColor(Resources.Colors.green, renderingMode: .alwaysOriginal)
    }
}
