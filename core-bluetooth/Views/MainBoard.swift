//
//  MainBoard.swift
//  core-bluetooth
//
//  Created by Алиночка Ш on 06.06.2023.
//

import SwiftUI

struct MainBoard: View {
    var body: some View {
        VStack {
            Text("Проверить посещаемость")
                .font(.title2).bold().padding()
            Button("СКАНИРОВАТЬ") {
                print("Action")
            }
            .padding()
            .font(.custom("", size: 20))
            .background(Color("Violet"))
            
            
                
            
            
        }
        
    }
}

struct MainBoard_Previews: PreviewProvider {
    static var previews: some View {
        MainBoard()
    }
}
