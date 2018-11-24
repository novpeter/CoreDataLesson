//
//  DataManager.swift
//  VKClone
//
//  Created by Петр on 18/11/2018.
//  Copyright © 2018 DreamTeam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class DBManager: DBManagerProtocol {
    
    static let sharedInstance = DBManager()
    
    // MARK: - CoreData utils
    
    lazy var persistentContainer: NSPersistentContainer? = {
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate
            else { return nil }
        
        return delegate.persistentContainer
    }()
    
    lazy var context: NSManagedObjectContext = {
        return self.persistentContainer!.viewContext
    }()
    
    func saveContext () {
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        }
        catch let error{
            print("Cannot save context \(error)")
        }
    }
    
    
    private init() {

        Generator.generateAndSaveRandomUser(context: context)
    }
    
    
    // MARK: - DBManager utils
    
    /// Return model from database
    ///
    /// - Parameter type: type of model
    /// - Returns: the model
    func get<T>( with type: T.Type, predicate: (T) -> Bool ) -> T? where T : NSManagedObject {
        
        let request = T.fetchRequest()
        var result: [T] = []
        
        if let models = try? context.fetch(request) as! [T] {
            
            for model in models {
                
                if predicate(model) {
                    result.append(model)
                }
            }
        }
        
        return result.count > 0 ? result.first : nil
    }
    
    /// Return all entities of given type
    ///
    /// - Parameter type: type of models
    /// - Returns: the set of models
    func getAll<T>(with type: T.Type, predicate: (T) -> Bool ) -> [T]? where T : NSManagedObject {
        
        let request = T.fetchRequest()
        var result: [T] = []
        
        if let models = try? context.fetch(request) as! [T] {
            
            for model in models {
                
                if predicate(model) {
                    result.append(model)
                }
            }
        }
        
        return result
    }
    
    /// Update given model in database
    ///
    /// - Parameter model: model to save
    func update<T>(model: T) where T : NSManagedObject {
        
        let predicate = {(currentModel: T) -> Bool in return currentModel == model}
        
        if let oldModel = self.get(with: type(of: model), predicate: predicate) {
            
            context.delete(oldModel)
            self.saveContext()
            
            return
        }
        
        
    }
    
    /// delete given model from database
    ///
    /// - Parameter model: model
    func delete<T>(model: T) where T : NSManagedObject {
        
        context.delete(model)
        self.saveContext()
    }
    
}