import Foundation


public struct GroupData: Decodable {
    let groups: [Group]
}

public struct Group: Decodable {
    let group: String
    let id: Int
    let students: [Student]
}

public struct Student: Decodable {
    let name: String
    let id: Int
    let uuid: String
}




public func readJSONData() throws -> GroupData {
    // Определите путь к JSON-файлу
    guard let fileURL = Bundle.main.url(forResource: "data", withExtension: "json") else {
        fatalError("JSON file not found")
    }
    
    do {
        // Чтение данных из файла
        let jsonData = try Data(contentsOf: fileURL)
        
        // Создание JSONDecoder
        let decoder = JSONDecoder()
        
        // Распарсинг данных в экземпляр структуры GroupData
        let groupData = try decoder.decode(GroupData.self, from: jsonData)
        
        // Возвращение полученных данных
        return groupData
    } catch {
        print("Error reading JSON: \(error)")
        throw error
    }
}



