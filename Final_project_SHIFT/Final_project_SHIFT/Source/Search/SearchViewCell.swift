//
//  SearchViewCell.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SnapKit
import UIKit

struct SearchCellModel {
    let fullName: String
    let symbol: String
    let type: String
}

final class SearchViewCell: UICollectionViewCell {
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
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
        self.contentView.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
        }
        
        self.contentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.leading.equalTo(fullNameLabel)
            make.bottom.equalToSuperview().inset(16)
        }
        
        self.contentView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configure() {
        self.contentView.layer.cornerRadius = 15
        self.contentView.backgroundColor = .systemGray.withAlphaComponent(0.3)
    }
    
    func setModel(with model: SearchCellModel) {
        fullNameLabel.text = model.fullName
        symbolLabel.text = model.symbol
        typeLabel.text = model.type
    }
}
