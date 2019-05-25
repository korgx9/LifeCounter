//
//  PerifiralViewController.swift
//  LifeCounter
//
//  Created by kokozzz on 25/5/19.
//  Copyright © 2019 kokozzz. All rights reserved.
//

import UIKit
import CoreBluetooth

class PerifiralViewController: UIViewController {
    
    var selectedPeripheral : CBPeripheral? { didSet { buttonSend.isEnabled = selectedPeripheral != nil } }
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    var rx: CBMutableCharacteristic?
    
    var identifier: String!
    var name: String!
    
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var labelLife: UILabel!
    
    @IBAction func sendHandler(_ sender: Any) {
        rx!.value = "\(UIDevice.current.name): YO LO LO".data(using: .utf8)!
        peripheralManager?.updateValue(rx!.value!, for: rx!, onSubscribedCentrals: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonSend.isEnabled = false
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func initService() {
        
        let serialService = CBMutableService(type: SERVICE_UUID, primary: true)
        let rx = CBMutableCharacteristic(type: RX_UUID, properties: RX_PROPERTIES, value: nil, permissions: RX_PERMISSIONS)
        
        serialService.characteristics = [rx]
        self.rx = rx
        peripheralManager?.add(serialService)
        
        rx.value = "zhopa".data(using: .utf8)
    }
}

extension PerifiralViewController : CBPeripheralDelegate {
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(#function)
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        print(#function)
        if peripheral == selectedPeripheral {
            for characteristic in service.characteristics! {
                if (characteristic.uuid.isEqual(RX_UUID)) {
//                    peripheral.writeValue("\(UIDevice.current.name): YO LO LO".data(using: .utf8)!,
//                                          for: characteristic,
//                                          type: CBCharacteristicWriteType.withoutResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        if let messageText = String(data: characteristic.value!, encoding: String.Encoding.utf8) {
            labelLife.text = (labelLife.text ?? "") + messageText + "\n"
        }
    }
    
}

extension PerifiralViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(#function)
        if (peripheral.state == .poweredOn){
            initService()
        }
    }
    
    // receive
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print(#function)
        for request in requests {
            if let value = request.value {
                if let messageText = String(data: value, encoding: String.Encoding.utf8) {
                    labelLife.text = (labelLife.text ?? "") + messageText + "\n"
                }
            }
            //            self.peripheralManager.respond(to: request, withResult: .success)
        }
    }
    
}

extension PerifiralViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(#function)
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: [SERVICE_UUID],
                                                    options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
    }
    
    // discover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(#function)
        if (peripheral.identifier.uuidString == identifier) {
            selectedPeripheral = peripheral
            centralManager?.connect(selectedPeripheral!, options: nil)
        }
    }
    
    // connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(#function)
        selectedPeripheral?.delegate = self
        selectedPeripheral?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(#function)
        centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(#function)
        print("## \(error?.localizedDescription ?? "nill error")")
    }
    
}
