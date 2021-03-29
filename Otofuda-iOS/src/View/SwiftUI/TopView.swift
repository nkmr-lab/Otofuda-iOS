//
//  TopView.swift
//  Otofuda-iOS
//
//  Created by 新納真次郎 on 2021/03/16.
//  Copyright © 2021 nkmr-lab. All rights reserved.
//

import SwiftUI

struct TopView: View {
    var backgroundColor: Color = .yellow
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
