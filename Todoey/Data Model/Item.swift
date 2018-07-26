//
//  Item.swift
//  Todoey
//
//  Created by Michelle on 2018-07-25.
//  Copyright © 2018 Michelle Chin. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
