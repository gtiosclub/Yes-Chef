//
//  StepsInputView.swift
//  Yes Chef
//
//  Created by Anushka Jain on 9/24/25.
//

import SwiftUI

struct StepsInputView: View {
    @Binding var steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(steps.indices, id: \.self) { index in
                HStack(alignment: .center) {
                    Text(String(format: "%02d", index + 1))
                        .font(.title)
                        .frame(width: 40, alignment: .center)

                    TextField("Enter step...", text: $steps[index])
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .foregroundColor(.secondary)

                    if steps.count > 1 {
                        Button(action: {
                            steps.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Button(action: {
                            steps.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Step")
                            }
                            .font(.subheadline)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
    }
}

#Preview {
    StepsInputView(steps: .constant([""]))
}
