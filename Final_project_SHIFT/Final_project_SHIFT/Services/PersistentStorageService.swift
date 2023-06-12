//
//  PersistentStorageService.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 12.06.2023.
//

import CoreData
import UIKit

//protocol ImageSaverServiceDelegate: AnyObject {
//    func saveImageToCoreData(image: UIImage, url: URL)
//    func loadImageFromCoreData() -> [ImageModel]?
//}

struct PersistentStorageServiceModel {
    let ticker: String
    let name: String
    let logo: String
    let currency: String
    var price: Double
    let isFavorite: Bool
}

final class PersistentStorageService {
    func saveStockToCoreData(ticker: String, name: String, logo: String, currency: String, price: Double, isFavorite: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Создаем новую сущность
        guard let entity = NSEntityDescription.entity(forEntityName: "StockEntity", in: context) else {
            print("no  entity"); return
        }
        
        let newObject = NSManagedObject(entity: entity, insertInto: context)
        
        newObject.setValue(ticker, forKey: "ticker")
        newObject.setValue(name, forKey: "name")
        newObject.setValue(logo, forKey: "logo")
        newObject.setValue(currency, forKey: "currency")
        newObject.setValue(price, forKey: "price")
        newObject.setValue(isFavorite, forKey: "isFavorite")
        
        // Сохраняем изменения в контексте
        do {
            try context.save()
            print("Акция сохранена в Core Data.")
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
    }
    
    func isStockFavorite(ticker: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StockEntity")
        fetchRequest.predicate = NSPredicate(format: "ticker == %@ AND isFavorite == %@", ticker, true as NSNumber)
        fetchRequest.fetchLimit = 1
        
        do {
            let context = appDelegate.persistentContainer.viewContext
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to fetch stock: \(error)")
            return false
        }
    }

    
    func loadStocksFromCoreData() -> [PersistentStorageServiceModel]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Создаем запрос на получение сущностей
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StockEntity")
        
        do {
            // Получаем массив сущностей
            let entities = try context.fetch(fetchRequest)
            
            var stocksModel: [PersistentStorageServiceModel] = []
            for entity in entities {
                if let entity = entity as? NSManagedObject {
                    
                    if let ticker = entity.value(forKey: "ticker") as? String, let name = entity.value(forKey: "name") as? String, let logo = entity.value(forKey: "logo") as? String, let currency = entity.value(forKey: "currency") as? String, let price = entity.value(forKey: "price") as? Double, let isFavorite = entity.value(forKey: "isFavorite") as? Bool {

                        let stock = PersistentStorageServiceModel(ticker: ticker, name: name, logo: logo, currency: currency, price: price, isFavorite: isFavorite)
                        stocksModel.append(stock)
                    }
                }
            }
            
            return stocksModel
        } catch {
            print("Ошибка при загрузке акций из Core Data: \(error)")
        }
        
        return nil
    }
    
    func deleteAllStocks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        
        // Создание запроса на удаление для каждой сущности
        let entityNames = persistentContainer.managedObjectModel.entities.map { $0.name ?? "" }
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                // Выполнение запроса на удаление
                try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
            } catch {
                print("Ошибка при удалении объектов сущности \(entityName): \(error)")
            }
        }
        
        // Сохранение изменений
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
        }
        print("Все акции удалены")
    }
    
    func deleteStockBy(ticker: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StockEntity")
        
        fetchRequest.predicate = NSPredicate(format: "ticker == %@", ticker)
        
        do {
            // Выполняем запрос на получение сущностей, соответствующих предикату
            let fetchedEntities = try context.fetch(fetchRequest)
            
            for entity in fetchedEntities {
                if let stockEntity = entity as? NSManagedObject {
                    context.delete(stockEntity) // Удаляем сущность из контекста
                }
            }
            
            // Сохраняем изменения
            try context.save()
            
            print("Акция \(ticker) удалена из Core Data")
        } catch {
            print("Ошибка при удалении акции \(ticker): \(error)")
        }
    }

}
