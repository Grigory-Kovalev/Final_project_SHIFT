//
//  SearchViewCell.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SnapKit
import UIKit

final class SearchViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private enum Metrics {
        static let indexImageLeadingInset: CGFloat = 16
        static let indexImageLenghtSide: CGFloat = 30
        static let symbolLabelLeadingInset: CGFloat = 47
        static let symbolLabelBottomInset: CGFloat = 12
        static let fullNameLabelTopInset: CGFloat = 24
        static let fullNameLabelWidthOffset: CGFloat = -80
        static let contentViewCornerRadius: CGFloat = 15
        static let contentViewBorderWidth: CGFloat = 2
    }
    
    // MARK: - Subviews
    private lazy var indexImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Resources.Fonts.priceLabelFont
        return label
    }()
    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.font = Resources.Fonts.thickFont
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColor()
    }
    
    func setModel(with model: SearchCellModel) {
        fullNameLabel.text = model.fullName
        symbolLabel.text = model.symbol
        
        indexImage.image = UIImage(systemName: "\(model.index.description).circle.fill")?.withTintColor(Resources.Colors.green, renderingMode: .alwaysOriginal)
    }
}

// MARK: - Private Methods
private extension SearchViewCell {
    func setupUI() {
        self.contentView.addSubview(indexImage)
        indexImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.indexImageLeadingInset)
            make.centerY.equalToSuperview()
            make.height.equalTo(Metrics.indexImageLenghtSide)
            make.width.equalTo(Metrics.indexImageLenghtSide)
        }
        
        self.contentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.leading.equalTo(indexImage).inset(Metrics.symbolLabelLeadingInset)
            make.bottom.equalTo(indexImage.snp.centerY).inset(Metrics.symbolLabelBottomInset)
        }
        
        self.contentView.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(symbolLabel)
            make.top.equalTo(symbolLabel).inset(Metrics.fullNameLabelTopInset)
            make.width.equalToSuperview().offset(Metrics.fullNameLabelWidthOffset)
            
        }
    }
    
    func configure() {
        self.contentView.layer.cornerRadius = Metrics.contentViewCornerRadius
        self.contentView.backgroundColor = Resources.Colors.Search.cellBackground
        self.contentView.layer.borderWidth = Metrics.contentViewBorderWidth
        updateBorderColor()
    }
    
    func updateBorderColor() {
        self.contentView.layer.borderColor = currentThemeIsDark() ? Resources.Colors.Search.borderCellWhite : Resources.Colors.Search.borderCellBlack
    }
    
    func currentThemeIsDark() -> Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}
