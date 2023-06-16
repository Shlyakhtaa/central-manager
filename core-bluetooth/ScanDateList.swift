import SwiftUI

struct ScanDateList: View {
    var centralManager: CentralManager
    var groupData: GroupData?
    var deviceData: [UUID: String]
    
    init(centralManager: CentralManager) {
        self.centralManager = centralManager
        self.deviceData = centralManager.deviceData
        
        do {
            // Вызываем функцию readJSONData() для получения данных
            groupData = try readJSONData()
        } catch {
            print("Error reading JSON: \(error)")
            // Обработайте ошибку, если не удалось получить данные
        }
    }
    
    var body: some View {
        
        VStack{
            List{
                if let groupData = groupData {
                    ForEach(groupData.groups, id: \.id) { group in
                        ForEach(group.students, id: \.id) { student in
                            if student.uuid == deviceData.first(where: { $0.value == student.uuid })?.value {
                                Text("Name: \(student.name)")
                                    .foregroundColor(.blue)
                            } else {
                                Text("No matching device found for student: \(student.name)")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                } else {
                    Text("No group data available")
                        .foregroundColor(.gray)
                }
                
            }
         }
    }


        
        /*
        VStack {
            Text("Group: \(groupData?.groups.first?.group ?? "")")
            
            List {
                ForEach(deviceData.sorted(by: { $0.key.uuidString < $1.key.uuidString }), id: \.key) { (deviceUUID, deviceString) in
                    // Перебираем все записи в словаре deviceData
                    
                    // Ищем соответствующее значение по UUID в groupData
                    if let group = groupData?.groups.first(where: { $0.students.contains(where: { $0.uuid == deviceUUID.uuidString }) }) {
                        // Значение UUID найдено в groupData
                        
                        if let student = group.students.first(where: { $0.uuid == deviceUUID.uuidString }) {
                            // Найден студент с соответствующим UUID
                            
                            if group.group == deviceString {
                                // Значение String совпадает с group.group
                                
                                //Text("Совпадение найдено для UUID: \(deviceUUID.uuidString) и значения String: \(deviceString)")
                                Text("Name: \(student.name)")
                                // Выводите сообщение или выполняйте нужные вам действия здесь
                            } else {
                                // Значение String не совпадает с group.group
                                
                                Text("Не совпадает для UUID: \(deviceUUID.uuidString), ожидаемое значение: \(group.group), фактическое значение: \(deviceString)")
                                // Выводите сообщение или выполняйте нужные вам действия здесь
                            }
                        }
                    } else {
                        // Значение UUID не найдено в groupData
                        
                        Text("UUID не найден в groupData: \(deviceUUID.uuidString)")
                        // Выводите сообщение или выполняйте нужные вам действия здесь
                    }
                }
            }
        }*/
    }


struct ScanDateList_Previews: PreviewProvider {
    static var previews: some View {
        let centralManager = CentralManager()
        return ScanDateList(centralManager: centralManager)
    }
}


func findStudentWithUUID(uuid: String, in groupData: GroupData) -> Student? {
    for group in groupData.groups {
        for student in group.students {
            if student.uuid == uuid {
                return student
            }
        }
    }
    return nil
}
