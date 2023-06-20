import SwiftUI



struct StudentForTeacher {
    var uuid: UInt16
    var name: String
    var idDevice: UUID
}


private var key = textFieldgroupNumber.textGroupNumber



private var groupData: GroupData?
func hasDataForKey(_ textFieldGroupData: TextFieldGroupData) -> Bool {
   // let key = textFieldGroupData.textGroupNumber // Используйте textFieldGroupData как ключ
    
    if UserDefaults.standard.object(forKey: key) != nil {
        return true
    } else {
        // запрос на сервер + обработка данных
        
        do {
            groupData = try readJSONData()
        } catch {
            print("Error reading JSON: \(error)")
        }
        
    
        
        // Функция добавления данных о студентах в память устройства
        if let groups = groupData?.groups { // Извлекаем значение groups из groupData
            let newRecords: [UUID: StudentForTeacher] = groups.reduce(into: [:]) { result, group in
                let studentsForTeacher = group.students.reduce(into: [UUID: StudentForTeacher]()) { studentsDict, student in
                    let uuid = UUID()
                    let studentForTeacher = StudentForTeacher(uuid: student.uuid, name: student.name, idDevice: uuid)
                    studentsDict[uuid] = studentForTeacher
                }
                result = studentsForTeacher // Замените "someKey" на нужный вам ключ
            }

            // Создаем экземпляр StudentData
            var studentData = StudentData()

            // Добавляем новые данные в records
            studentData.records.append(newRecords)
        }
                
        return false
    }
}


// структура для сохранения данных о студентах в память приложения
struct StudentData {
    var records: [[UUID: StudentForTeacher]] {
        
        set {
            let serializedData = newValue.map { dictionary in
                dictionary.mapValues { record in
                    [
                        "uuid": record.uuid,
                        "name": record.name,
                        "idDevice": record.idDevice,
                    ]
                }
            }
            UserDefaults.standard.set(serializedData, forKey: key)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let serializedData = UserDefaults.standard.array(forKey: key) as? [[[String: Any]]] else {
                return []
            }
            
            return serializedData.map { dictionaryArray in
                dictionaryArray.reduce(into: [UUID: StudentForTeacher]()) { dictionary, dictionaryElement in
                    if let uuid = dictionaryElement["uuid"] as? UInt16,
                       let name = dictionaryElement["name"] as? String,
                       let idDeviceString = dictionaryElement["idDevice"] as? String,
                       let idDevice = UUID(uuidString: idDeviceString){
                        let record = StudentForTeacher(uuid: uuid, name: name, idDevice: idDevice)
                        dictionary[idDevice] = record
                    }
                }
            }
        }
    }
}



var userData: [[UUID: String]] {
    set {
        UserDefaults.standard.set(newValue, forKey: "userDataKey")
        UserDefaults.standard.synchronize()
    }
    get {
        if let data = UserDefaults.standard.array(forKey: "userDataKey") as? [[UUID: String]] {
            return data
        } else {
            return []
        }
    }
}

// функция проверки группы в памяти устройства
func hasDataForKey(_ key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}


struct ScanDateList: View {
    
    @State private var foundStudents: [Student] = []
    
    @State private var studentForTeacher: [StudentForTeacher] = []
    @EnvironmentObject var textGroupData: TextFieldGroupData
    @EnvironmentObject var scanDateArray: ScanDateArray
    var studentData = StudentData() // Используйте @StateObject для создания экземпляра
    
    
    
    var body: some View {
            VStack {
                
                List(Array(renderStudentRecords().map { ($0, $1) }), id: \.0) { name, isMatch in
                           Text(name)
                               .foregroundColor(isMatch ? .black : .red)
                       }
            }
        
        }
    
    func renderStudentRecords() -> [String: Bool] {
        var studentRecords: [String: Bool] = [:]
        
        for record in studentData.records {
            for (uuid, student) in record {
                let studentUUID = student.uuid
                let studentName = student.name
                let studentIDDevice = student.idDevice
                
                /*if let idDeviceString = scanDateArray.deviceData[studentIDDevice] {
                    let isMatch = idDeviceString == studentUUID
                    studentRecords[studentName] = isMatch
                }*/
            }
        }
        
        return studentRecords
    }

}

struct ScanDateList_Previews: PreviewProvider {
    static var previews: some View {
         ScanDateList()
    }
}

// Ваш код для структур GroupData, Group, Student и функции readJSONData()
// ...




// Ваш код для структуры CentralManager и инициализации данных deviceData
// ...
