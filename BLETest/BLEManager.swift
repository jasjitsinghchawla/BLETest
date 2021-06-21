//
//  BLEManager.swift
//  BLETest
//
//  Created by Jasjit Singh Chawla on 19/06/21.
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
    let identifier: UUID
    let code: String
}
struct MyPeripheral: Identifiable {
    let id: Int
    let peripheral: CBPeripheral
}


class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    var myCentral: CBCentralManager!
    var myPeripheral: CBPeripheral!
    let myPeripheralCUUID1 =  CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let myPeripheralCUUID2 =  CBUUID.init(string: "6E40A100-B5A3-F393-E0A9-E50E24DCCA9E")
    let myPeripheralCUUID3 =  CBUUID.init(string: "0x180F")
    let myScaleCBUUID1 = CBUUID.init(string: "4385B3F5-2953-C44E-D521-BFC7289F6757")
    let myPeripheralCharacteristicCUUID3 =  CBUUID.init(string: "0x2A19")
    
    
    @Published var myPeripherals = [MyPeripheral]()
    
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()

    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        } else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!!")
        myPeripherals[0].peripheral.discoverServices(nil)//([myPeripheralCUUID3])
        
        //myPeripherals[0].peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        var peripheralID: UUID!
        
        //print(peripheral)
        if let identified = peripheral.identifier as? UUID {
            peripheralID = identified
        } else {
            peripheralID = UUID(uuidString: "TEST")
        }
        
        //if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
        if let name = peripheral.name  {
            //if name == "F_ACE_5986" {
            if name == "Electronic Scale" {
                peripheralName = name

                let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, identifier: peripheralID,code: "")
                print(newPeripheral)
                let newMyPeripheral = MyPeripheral(id: myPeripherals.count, peripheral: peripheral)
                myPeripheral = peripheral
                myPeripherals.append(newMyPeripheral)
                peripherals.append(newPeripheral)
            }

        } else {
            peripheralName = "Unknown"
        }
        
//        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, identifier: peripheralID,code: "")
//        print(newPeripheral)
//        peripherals.append(newPeripheral)
    }
    
    func startScanning() {
        print("startScanning")
        myCentral.scanForPeripherals(withServices: nil, options: nil)
    
    }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
        connectDevice()
    }
    
    func connectDevice(){
        myPeripherals[0].peripheral.delegate = self
        myCentral.connect(myPeripherals[0].peripheral)
    }

}
extension BLEManager: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            print(service)
            print(service.characteristics ?? "Characteristics are nil")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case myPeripheralCharacteristicCUUID3:
            print(characteristic.value ?? "no value")
        default:
            print("inhandled characteristic UUID: \(characteristic.uuid)")
        }
    }
}
