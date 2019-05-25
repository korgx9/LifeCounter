//
//  AppDelegate.swift
//  LifeCounter
//
//  Created by kokozzz on 25/5/19.
//  Copyright © 2019 kokozzz. All rights reserved.
//

import UIKit
import CoreBluetooth

let SERVICE_UUID = CBUUID(string: "4DF91029-B356-463E-9F48-BAB077BF3EF5") //4DF91029-B356-463E-9F48-BAB077BF3EF5
let RX_UUID = CBUUID(string: "3B66D024-2336-4F22-A980-8095F4898C42")
let RX_PROPERTIES: CBCharacteristicProperties = [.notify, .read]
let RX_PERMISSIONS: CBAttributePermissions = .readable


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

}

