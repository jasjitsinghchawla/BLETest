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

fileprivate var ledMask: UInt8    = 0
fileprivate let digitalBits = 2 // TODO: each digital uses two bits

class BLEManager: NSObject, ObservableObject {
    var myCentral: CBCentralManager!
    var myPeripheral: CBPeripheral!
    let myPeripheralCUUID1 =  CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let myPeripheralCUUID2 =  CBUUID.init(string: "6E40A100-B5A3-F393-E0A9-E50E24DCCA9E")
    let myPeripheralCUUID3 =  CBUUID.init(string: "0x180F")
    let myScaleCBUUID1 = CBUUID.init(string: "4385B3F5-2953-C44E-D521-BFC7289F6757")
    let myPeripheralCharacteristicCUUID3 =  CBUUID.init(string: "0x2A19")
    
    
    let AceLightFront = CBUUID.init(string: "FDDAB01A-62C3-DB0A-98E8-F060EE99255E") // name = F_ACE_5986
    let ElectronicScale = CBUUID(string: "4385B3F5-2953-C44E-D521-BFC7289F6757") //"Electronic Scale"
    
    let Battery = CBUUID(string: "0x180F")
    let BatteryLevel = CBUUID(string: "0x2A19")
    let Light1 = CBUUID(string: "6E40A102-B5A3-F393-E0A9-E50E24DCCA9E")
    let Light2 = CBUUID(string: "6E40A102-B5A3-F393-E0A9-E50E24DCCA9E")
    let Light3 = CBUUID(string: "6E40A103-B5A3-F393-E0A9-E50E24DCCA9E")
    let Light4 = CBUUID(string: "6E40A104-B5A3-F393-E0A9-E50E24DCCA9E")
    
    let Digital = CBUUID(string: "0x2A56")
    
    let Weight1 = CBUUID(string: "0xFFF1") // 2A98 - Weight, 2A9D - Weight Measurement, 2A9E - Weight Scale feature, 181D FFF4
    let Weight2 = CBUUID(string: "0xFFF4")
    let Weight3 = CBUUID(string: "F000FFC2-0451-4000-B000-000000000000")
    let Weight4 = CBUUID(string: "0x2A98")
    let Weight5 = CBUUID(string: "0x2A9D")
    let Weight6 = CBUUID(string: "F000FFC1-0451-4000-B000-000000000000")
    let Weight7 = CBUUID(string: "F000FFC2-0451-4000-B000-000000000000") //"00002a9d-0000-1000-8000-00805f9b34fb"
    let Weight8 = CBUUID(string: "00002a9d-0000-1000-8000-00805f9b34fb")
    
    let DeviceInformation = CBUUID(string: "0x180A")
    let PnPID = CBUUID(string: "0x2A50")
    
    let SystemID = CBUUID(string: "0x2A23")
    let ModelNumber = CBUUID(string: "0x2A24")
    let SerialNumber  = CBUUID(string: "0x2A25")
    let FirmwareRevision = CBUUID(string: "0x2A26")
    let HardwareRevision = CBUUID(string: "0x2A27")
    let SoftwareRevision = CBUUID(string: "0x2A28")
    let ManufacturerName = CBUUID(string: "0x2A29")
    let IEEERegulatoryCertification = CBUUID(string: "0x2A2A")

    @Published var myPeripherals = [MyPeripheral]()
    
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()

    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }

    
    func startScanning() {
        print("startScanning")
        myCentral.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
    }
    
    func connectDevice(){
        myPeripherals[0].peripheral.delegate = self
        myCentral.connect(myPeripherals[0].peripheral)
    }
    
    func disconnectDevice(){
        print("Disconnect Device")
        myCentral.cancelPeripheralConnection(myPeripherals[0].peripheral)
    }

}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        } else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        var peripheralID: UUID!
        
        guard peripheral.name != nil else {return}
        
        if let name = peripheral.name {
            if (peripheral.identifier.description == AceLightFront.uuidString.description ) {
                print("\(peripheral.name ?? "Not") Found")
                let newMyPeripheral = MyPeripheral(id: myPeripherals.count, peripheral: peripheral)
                //myPeripheral = peripheral
                print(peripheral)
                
                myPeripherals.append(newMyPeripheral)
                //stopScanning()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected: \(peripheral.name  ?? "No Name!!")")
        //peripheral.discoverServices([myPeripheralCUUID3])
        //myPeripherals[0].peripheral.discoverServices([myPeripheralCUUID3])
        myPeripherals[0].peripheral.discoverServices(nil)
        
        //myPeripherals[0].peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected : \(peripheral.name  ?? "No Name")")
        myCentral.scanForPeripherals(withServices: nil, options: nil)
    }
}

extension BLEManager: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            print("Service discovered : \(service)")
            //print(service.characteristics ?? "Characteristics are nil")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics {
            //print("\(characteristic.uuid) - \(characteristic)")
            //MARK:- Light Value
            if characteristic.uuid == Digital {
                  //write value
                setDigitalOutput(1, on: true, characteristic: characteristic)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.setDigitalOutput(1, on: true, characteristic: characteristic)
                })
            }
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        
        case PnPID:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            
            print("Characteristic value tb_int16 : \(level)")

        case DeviceInformation:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")

        case Weight1:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")
            
        case Weight2:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")
        case Weight3:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")
        case Weight4:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")
        case Weight5:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")

        case Weight6:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")
        case Weight7:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")
        case Weight8:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.weightValue()
            print("Characteristic value tb_int16 : \(level1)")

        case myPeripheralCharacteristicCUUID3:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
            
        case SystemID:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
        case ModelNumber:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
        case SerialNumber:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")

        case FirmwareRevision:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
        case HardwareRevision:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
        case SoftwareRevision:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
        case IEEERegulatoryCertification:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
        case Light1:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            guard let data = characteristic.value else {
                    // no data transmitted, handle if needed
                    return
                }
            guard data.count == 4 else {
                // handle unexpected number of bytes
                return
            }
            let red   = data[0]
            let green = data[1]
            let blue  = data[2]
            let yello = data[3]
            print("R: \(red)", "G: \(green)", "B: \(blue)","Y: \(yello)", separator: " | ")
        case Light2:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            print(characteristic.value?.base64EncodedData())
            guard let data = characteristic.value else {
                    // no data transmitted, handle if needed
                    return
                }
            guard data.count == 4 else {
                // handle unexpected number of bytes
                return
            }
            let red   = data[0]
            let green = data[1]
            let blue  = data[2]
            let yello = data[3]
            print("A: \(red)", "B: \(green)", "C: \(blue)","D: \(yello)", separator: " | ")
        case Light3:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            print(characteristic.value?.base64EncodedString())
            guard let data = characteristic.value else {
                    // no data transmitted, handle if needed
                    return
                }
            guard data.count == 4 else {
                // handle unexpected number of bytes
                return
            }
            let red   = data[0]
            let green = data[1]
            let blue  = data[2]
            let yello = data[3]
            print("A: \(red)", "B: \(green)", "C: \(blue)","D: \(yello)", separator: " | ")
            
        default:
            print("Characteristic \(characteristic.uuid) value description - \(characteristic.value?.description ?? "No value description")")
            let level = characteristic.tb_int16Value()
            print("Characteristic value tb_int16 : \(level)")
            let level1 = characteristic.tb_uint16Value()
            print("Characteristic value tb_int16 : \(level1)")
        }
    }
    
   
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("WRITE VALUE : \(characteristic)")
    }
    
    fileprivate func setDigitalOutput(_ index: Int, on: Bool, characteristic  :CBCharacteristic) {
               let shift = UInt(index) * UInt(digitalBits)
               var mask = ledMask
               
               if on {
                   mask = mask | UInt8(1 << shift)
               }
               else {
                   mask = mask & ~UInt8(1 << shift)
               }
               
               let data = Data(bytes: [mask])
        self.myPeripheral.writeValue(data, for: characteristic, type: .withResponse)
               //self.bleDevice.writeValueForCharacteristic(CBUUID.Digital, value: data)
               
               // *** Note: sending notification optimistically ***
               // Since we're writing the full mask value, LILO applies here,
               // and we *should* end up consistent with the device. Waiting to
               // read back after write causes rubber-banding during fast write sequences. -tt
               ledMask = mask
              // notifyLedState()
           }
    
    fileprivate func setOutput(_ index: Int, on: Bool, characteristic  :CBCharacteristic) {
               let shift = UInt(index) * UInt(digitalBits)
               var mask = ledMask
               
               if on {
                   mask = mask | UInt8(1 << shift)
               }
               else {
                   mask = mask & ~UInt8(1 << shift)
               }
               
               let data = Data(bytes: [mask])
        self.myPeripheral.writeValue(data, for: characteristic, type: .withResponse)
               //self.bleDevice.writeValueForCharacteristic(CBUUID.Digital, value: data)
               
               // *** Note: sending notification optimistically ***
               // Since we're writing the full mask value, LILO applies here,
               // and we *should* end up consistent with the device. Waiting to
               // read back after write causes rubber-banding during fast write sequences. -tt
               ledMask = mask
              // notifyLedState()
           }
    
}

extension CBCharacteristic  {
   func tb_int16Value() -> Int16? {
        if let data = self.value {
            var value: Int16 = 0
            (data as NSData).getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
    func tb_uint16Value() -> UInt16? {
        if let data = self.value {
            var value: UInt16 = 0
            (data as NSData).getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
    func weightValue() -> Int {
      guard let characteristicData = self.value else { return -1 }
      let byteArray = [UInt8](characteristicData)

      let firstBitValue = byteArray[0] & 0x01
      if firstBitValue == 0 {
        // Heart Rate Value Format is in the 2nd byte
        return Int(byteArray[1])
      } else {
        // Heart Rate Value Format is in the 2nd and 3rd bytes
        return (Int(byteArray[1]) << 8) + Int(byteArray[2])
      }
    }
}

