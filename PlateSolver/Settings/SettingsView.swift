//
//  SettingsView.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/29/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var apiKey = ""
    
    let onSaveKey: (String) -> Void
    
    init(onSaveKey: @escaping (String) -> Void) {
        self.onSaveKey = onSaveKey
        if let key = UserDefaults().string(forKey: APIService.Constants.apiKey) {
            _apiKey = .init(initialValue: key)
        }
    }
    
    func saveApiKey() {
        UserDefaults().set(apiKey,
                           forKey: APIService.Constants.apiKey)
        onSaveKey(apiKey)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("API Settings") {
                    TextField("API Key", text: $apiKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit {
                            saveApiKey()
                        }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        saveApiKey()
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Done")
                    })
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onSaveKey: {_ in })
    }
}
