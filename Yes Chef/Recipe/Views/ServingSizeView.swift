import SwiftUI

struct ServingSizeView: View {
    @Binding var servingSizeCount: ServingSize
    let option = ServingSize.allCases
    @State private var isExpanded = false
    
    var body: some View{
        HStack(spacing: 20){
            Image(systemName: "person.2.fill").resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    HStack {
                        Text(servingSizeCount.rawValue)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke())
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(option, id: \.self) { option in
                            Text(option.rawValue)
                                .padding()
                                .onTapGesture {
                                    servingSizeCount = option
                                    withAnimation { isExpanded = false }
                                }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 8).stroke())
                }
            }
        }
    }
}
struct ServingSizeView_Previews: PreviewProvider {
    static var previews: some View {
        ServingSizeView(servingSizeCount: .constant(ServingSize.five))
    }
}
