//
//  ServingSizeView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/30/25.
//
import SwiftUI

struct ServingSizeView: View {
    @Binding var servingSizeCount: ServingSize
    let option = ServingSize.allCases
    var body: some View{
        HStack(spacing: 20){
            Image(systemName: "person.2.fill").resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            VStack(spacing: 20) {
                        Text("Selected: \(servingSizeCount)")

                        Menu {
                            ForEach(option, id: \.self) { option in
                                Button(option.rawValue) {
                                    servingSizeCount = option
                                }
                            }
                        } label: {
                            Label("Choose serving size", systemImage: "chevron.down.circle")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).stroke())
                        }
                    }
                    .padding()
                }
        }
}
struct ServingSizeView_Previews: PreviewProvider {
    static var previews: some View {
        ServingSizeView(servingSizeCount: .constant(ServingSize.five))
    }
}
