import SwiftUI

struct StepsInputView: View {
    @Binding var steps: [String]
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Steps")
                    .font(.title)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isEditing.toggle()
                        if isEditing, steps.isEmpty {
                            steps = [""]
                        }
                    }
                } label: {
                    if isEditing {
                        Text("Done")
                            .font(.subheadline).bold()
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .foregroundColor(.black)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Color.gray.opacity(0.3)))
                    }
                }
            }
            .padding(.horizontal)

            ForEach(steps.indices, id: \.self) { index in
                HStack(alignment: .center, spacing: 10) {
                    Text(String(format: "%02d", index + 1))
                        .font(.title)
                        .frame(width: 40, alignment: .center)

                    TextField("Enter step...", text: $steps[index])
                        .disabled(!isEditing)
                        .opacity(isEditing ? 1 : 0.6)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .foregroundColor(.secondary)

                    if isEditing && steps.count > 1 {
                        Button {
                            steps.remove(at: index)
                        } label: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: "minus")
                                        .foregroundColor(.black)
                                        .font(.title3)
                                )
                        }
                    }

                    // Static reorder icon (no functionality yet)
                    if isEditing {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.black)
                                    .font(.title3)
                            )
                    }
                }
                .padding(.horizontal)
            }

            if isEditing {
                HStack {
                    Spacer()
                    Button {
                        steps.append("")
                    } label: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .font(.title3)
                            )
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    StepsInputView(steps: .constant(["Preheat oven to 350°F."]))
}
