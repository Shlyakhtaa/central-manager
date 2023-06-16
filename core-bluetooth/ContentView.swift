import SwiftUI
import CoreBluetooth
import Combine

class CentralManag: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    //MARK:- Properties
    
    // Центральный менеджер Bluetooth
    var centralManager: CBCentralManager!
    
    // Периферийное устройство Bluetooth
    var peripheral: CBPeripheral!
    
    // Характеристика Bluetooth
    var characteristic: CBCharacteristic?
    
    // Массив имен обнаруженных периферийных устройств
    @Published var peripheralNames: [String] = []
    
    // Словарь для хранения данных характеристики по идентификатору устройства
    var deviceData: [UUID: String] = [:]
    
    // Combine Publisher для обновления данных характеристики
    let characteristicDataPublisher = PassthroughSubject<(UUID, String?), Never>()
    
    // Combine Publisher для пользовательских данных
    let userDetailsPublisher = PassthroughSubject<String?, Never>()
    
    // Timer для автоматической остановки сканирования через 5 минут
    var scanTimer: Timer?
    let scanDuration: TimeInterval = 300 // 5 minutes

    
    //MARK:- CBCentralManagerDelegate Methods
    
    // Метод вызывается при обновлении состояния центрального менеджера
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Central Manager is powered on")
            
            // Сканирование периферийных устройств с определенными сервисами
            self.centralManager.scanForPeripherals(
                withServices: [CBUUID(string: "D9D9D9FB-8C28-4C5E-94E9-58C23B7C69E2")],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            )
            
            // Запуск таймера для остановки сканирования через 5 минут
            scanTimer = Timer.scheduledTimer(
                timeInterval: scanDuration,
                target: self,
                selector: #selector(stopScanning),
                userInfo: nil,
                repeats: false
            )
        } else {
            print("Central Manager is not powered on")
        }
    }

    
    // Метод вызывается при обнаружении периферийного устройства
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        print("Peripheral discovered: \(peripheral.name ?? "Unknown")")
        
        // Получение данных производителя (manufacturer data)
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let userDetailsString = String(data: manufacturerData, encoding: .utf8)
            print("User details received: \(userDetailsString ?? "")")
            
            // Получение идентификатора устройства
            let deviceIdentifier = peripheral.identifier
            
            // Сохранение данных характеристики в словаре по идентификатору устройства
            deviceData[deviceIdentifier] = userDetailsString
            
            // Оповещение об обновлении данных характеристики
            characteristicDataPublisher.send((deviceIdentifier, userDetailsString))
            
            // Оповещение о пользовательских данных
            userDetailsPublisher.send(userDetailsString)
        }
        
        // Остановка сканирования
        //self.centralManager.stopScan()
        
        // Сохранение ссылки на периферийное устройство и установка его делегата
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        
        /*
         // Подключение к периферийному устройству
         self.centralManager.connect(self.peripheral, options: nil)*/
    }
    
    /* // Метод вызывается при успешном подключении к периферийному устройству
     func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
     print("Peripheral connected")
     
     // Поиск сервисов на периферийном устройстве
     peripheral.discoverServices(nil)
     }*/
    
    //MARK:- CBPeripheralDelegate Methods
    
    // Метод вызывается при обнаружении сервисов на периферийном устройстве
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        print("Services discovered")
        
        // Поиск нужного сервиса
        for service in peripheral.services ?? [] {
            if service.uuid == CBUUID(string: "D9D9D9FB-8C28-4C5E-94E9-58C23B7C69E2") {
                print("Service: \(service.uuid.uuidString)")
                
                // Поиск характеристик в сервисе
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // Метод вызывается при обнаружении характеристик на периферийном устройстве
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        print("Characteristics discovered")
        
        // Поиск нужной характеристики
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == CBUUID(string: "D9D9D9FB-8C28-4C5E-94E9-58C23B7C69E2") {
                self.characteristic = characteristic
                
                // Чтение значения характеристики
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    // Метод вызывается при обновлении значения характеристики
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
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
    
    // Метод для запуска центрального менеджера
    func start() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func stopScanning() {
        self.centralManager.stopScan()
        self.scanTimer?.invalidate()
        self.scanTimer = nil
    }

}

    struct ContentView: View {
        @StateObject var centralManager = CentralManag()
        
        var body: some View {
            Text("Central Hello, World!")
                .onAppear {
                    // centralManager.start()
                }
        }
    }
