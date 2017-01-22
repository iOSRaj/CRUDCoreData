//
//  Group.swift
//  SwiftCoreDataSimpleDemo
//
//  Created by Raj on 14-8-28.
//  Copyright (c) 2016年 . All rights reserved.
//

import Foundation
import CoreData

@objc(Group)
class Group: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var deviceID: String
    @NSManaged var messageID: String
    @NSManaged var syncStatus: Bool
    @NSManaged var devices: Set<Device>
    @NSManaged var messages: Set<Message>
}
