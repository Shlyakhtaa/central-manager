import SwiftUI
import CoreBluetooth
import Combine

class CentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    //MARK:- Properties
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic?
    
    // Combine Publisher for User Details
    let userDetailsPublisher = PassthroughSubject<String?, Never>()
    
    //MARK:- CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Central Manager is powered on")
            self.centralManager.scanForPeripherals(withServices: [CBUUID(string: "D9D9D9FB-8C28-4C5E-94E9-58C23B7C69E2")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            print("Central Manager is not powered on")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral discovered: \(peripheral.name ?? "Unknown")")
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let userDetailsString = String(data: manufacturerData, encoding: .utf8)
            print("User details received: \(userDetailsString ?? "")")
            userDetailsPublisher.send(userDetailsString)
        }
        self.centralManager.stopScan()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral connected")
        peripheral.discoverServices(nil)
    }
    
    //MARK:- CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        print("Services discovered")
        for service in peripheral.services ?? [] {
            if service.uuid == CBUUID(string: "D9D9D9FB-8C28-4C5E-94E9-58C23B7C69E2") {
                print("Service: \(service.uuid.uuidString)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        print("Characteristics discovered")
        for characteristic in service.characteristics ?? [] {
            //print("Characteristic: \(characteristic.uuid.uuidString)")
            if characteristic.uuid == CBUUID(string: "D9D9D9FB-8C28-4C5E-94E9-58C23B7C69E2") {
                self.characteristic = characteristic
                peripheral.readValue(for: characteristic)
            }
        }
    }

    
        /* func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value: \(error.localizedDescription)")
            return
        }
        if characteristic.uuid == CBUUID(string: "D9D9D9FB-8C28-4C5E-94E9-58C23B7C69E2") {
            if let value = characteristic.value {
                let userDetails = String(data: value, encoding: .utf8)
                print("User Details: \(userDetails ?? "Unknown")")
                userDetailsPublisher.send(userDetails)
            }
        }
    }*/
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
            return
        }
        
        if let data = characteristic.value {
            let bytes = [UInt8](data)
            let hexString = String(bytes.first ?? 0, radix: 16)
            print("Characteristic value: \(hexString)")
        } else {
            print("Characteristic value is nil")
        }


    }


    
    //MARK:- Helper Methods
    func start() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}


struct ContentView: View {
    @StateObject var centralManager = CentralManager()
    
    var body: some View {
        Text("Central Hello, World!")
            .onAppear {
                centralManager.start()
            }
    }
}
