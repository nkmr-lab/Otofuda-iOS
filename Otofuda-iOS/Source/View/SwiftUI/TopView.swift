
import OtofudaResource
import SwiftUI

struct TopView: View {
    var backgroundColor: Color = .yellow
    var body: some View {
        ZStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            backgroundColor
            Image(uiImage: Asset.Images.topBackground.image)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
