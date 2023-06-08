//
//  DetailViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SnapKit
import SwiftUI
import UIKit

class DetailViewController: UIViewController {

    private let stockDetailModel: StockDetailModel
    
    init(stockDetailModel: StockDetailModel) {
        self.stockDetailModel = stockDetailModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = DetailSwiftUI(selectedResolution: stockDetailModel.currentRange.getTag(), data: Candles.getCandles(candles: stockDetailModel.candles), stock: stockDetailModel)
         let hostingController = UIHostingController(rootView: swiftUIView)
         
         addChild(hostingController)
         view.addSubview(hostingController.view)
         hostingController.view.translatesAutoresizingMaskIntoConstraints = false
         
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//         NSLayoutConstraint.activate([
//             hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//             hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//             hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
//             hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//         ])
         
         hostingController.didMove(toParent: self)
    }
}
