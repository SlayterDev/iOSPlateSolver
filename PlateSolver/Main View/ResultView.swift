//
//  ResultView.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/28/22.
//

import SwiftUI

struct ResultView: View {
    let url: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Result")
                    .font(.headline)
                Spacer()
            }
            AsyncImage(url: URL(string: url)) { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
                    .frame(width: 55, height: 55)
            }
        }
        .padding()
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(url: "http://nova.astrometry.net/annotated_display/6623400")
    }
}
