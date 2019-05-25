//
//  ViewController.swift
//  LifeCounter
//
//  Created by kokozzz on 25/5/19.
//  Copyright © 2019 kokozzz. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Device: Codable {
    let name: String
    let identifier: String
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var devices: [Device] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPerefirals" {
            if let viewController = segue.destination as? PerifiralViewController, let selectedRow = tableView.indexPathForSelectedRow?.row {
                viewController.identifier = devices[selectedRow].identifier
                viewController.name = devices[selectedRow].name
            }
        }
    }
    
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func updateAdvertisingData() {
        
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let advertisementData = "qw \(arc4random()%10)"
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[SERVICE_UUID],
                                            CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "some_reuse_ident", for: indexPath)
        debugPrint("index path = \(indexPath.row) deviceName = \(devices[indexPath.row].name)")
        cell.textLabel?.text = devices[indexPath.row].name
        cell.detailTextLabel?.text = devices[indexPath.row].identifier
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPerefirals", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(#function)
        if (peripheral.state == .poweredOn){
            updateAdvertisingData()
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(#function)
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: [SERVICE_UUID],
                                                    options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(#function)
        guard let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        
        let device = Device(name: name, identifier: peripheral.identifier.uuidString)
        if !(devices.contains { $0.identifier == device.identifier }) {
            devices.append(device)
        }
        tableView.reloadData()
    }
}
