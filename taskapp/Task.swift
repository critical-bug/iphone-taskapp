//
//  Task.swift
//  taskapp
//
//  Created by 	 on 01/16月.
//  Copyright © 2017年 critical-bug. All rights reserved.
//

import RealmSwift

class Task: Object {
    dynamic var id = 0
    dynamic var title = ""
    dynamic var content = ""
    dynamic var date = NSDate()
    override static func primaryKey() -> String? {
        return "id"
    }
}
