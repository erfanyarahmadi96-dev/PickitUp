//
//  LeavingModeView.swift
//  PickitUp
//
//  Created by Burak Demirhan on 10/03/26.
//

import SwiftUI


struct LeavingModeView: View {

    var pocket: Pocket
    @Environment(\.dismiss) var dismiss

    var body: some View {

        VStack(spacing: 24) {

            Text("Ready to leave?")
                .font(.largeTitle.bold())

            Text(pocket.name)
                .font(.title2)

            VStack(spacing: 12) {

                ForEach(pocket.items) { item in

                    HStack {

                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)

                        Text(item.name)

                        Spacer()
                    }
                }
            }
            .padding()

            HStack(spacing: 16) {

                Button("I'm Ready") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Edit Pocket") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
