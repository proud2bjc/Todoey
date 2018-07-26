//
//  Category.swift
//  Todoey
//
//  Created by Michelle on 2018-07-25.
//  Copyright © 2018 Michelle Chin. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    
    // create array List is equivalent to array with RealmSwift
    let items = List<Item>()
    
    
    
    
}

