//
//  ContentView.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/27/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var apiService = APIService()
    
    @State var image: Image? = nil
    @State var showCaptureImageView: Bool = false
    @State var showSettingsView: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    if let errorState = apiService.errorState {
                        Text(errorState.rawValue)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    
                    Button(action: {
                        self.showSettingsView.toggle()
                    }, label: {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    })
                    .padding(.trailing)
                }
                
                Spacer()
            }
            
            VStack {
                if let _ = image {
                    CaptureButton(image: $image,
                                  showCaptureImageView: $showCaptureImageView)
                } else {
                    PhotoButton(showCaptureImageView: $showCaptureImageView)
                }
                
                if apiService.status == .processing {
                    HStack {
                        Text(apiService.status.rawValue)
                            .foregroundColor(Color(.sRGB, red: 0.65, green: 0.5, blue: 0.0, opacity: 1.0))
                        ProgressView()
                            .padding(.leading)
                    }
                    Button(action: {
                        if let subUrl = apiService.currentSubUrl() {
                            UIApplication.shared.open(subUrl)
                        }
                    }, label: {
                        Text("Detailed Progress >")
                    })
                }
                
                if apiService.status == .done || apiService.solvedUrl != nil {
                    if let url = apiService.solvedUrl {
                        ResultView(url: url)
                    }
                }
            }
            .onAppear() {
                apiService.login()
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView(onSaveKey: { key in
                    apiService.apiKey = key
                })
            }
            
            if (showCaptureImageView) {
                CaptureImageView(isShown: $showCaptureImageView,
                                 image: $image,
                                 apiService: .constant(apiService))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
