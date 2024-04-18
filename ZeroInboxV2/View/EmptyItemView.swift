//
//  EmptyItemView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 12/26/23.
//

import SwiftUI

struct EmptyItemView: View {
    let title: String
    let subTitle: String
    
    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 50, height: 50)
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
            Text(subTitle)
                .font(.subheadline)
        }
        .foregroundStyle(.gray)
    }
}


/*
#Preview {
    EmptyItemView(isTask: true)
}*/

