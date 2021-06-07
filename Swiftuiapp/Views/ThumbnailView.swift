import SwiftUI

struct ThumbnailView: View {
    let url: URL

    @StateObject var viewModel = ThumbnailViewModel()

    var body: some View {
        Group {
            if let thumbnail = viewModel.thumbnail {
                Image(thumbnail, scale: (UIScreen.main.scale), label: Text(viewModel.imageLabel))
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo.fill")
                    .onAppear(perform: {
                        viewModel.generateThumbnail(url)
                    })
            }
        }
    }
}

struct ThumbnailView_Preview: PreviewProvider {
    static var previews: some View {
        ThumbnailView(url: URL(fileURLWithPath: ""))
    }
}

