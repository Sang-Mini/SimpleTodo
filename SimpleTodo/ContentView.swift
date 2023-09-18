//
//  ContentView.swift
//  SimpleTodo
//
//  Created by 유상민 on 2023/09/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("To-Do")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
