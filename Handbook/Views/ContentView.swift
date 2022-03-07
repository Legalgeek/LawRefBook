import SwiftUI
import CoreData

struct LawList: View {
    
    @State var searchText = ""
    @ObservedObject var law  = LawProvider.shared
    
    func content(uuid: UUID) -> some View {
        let content = LawProvider.shared.getLawContent(uuid)
        return LawContentView(lawID: uuid, content: content, isFav: LawProvider.shared.getFavoriteState(uuid)).onAppear {
            content.load()
        }
    }
    
    var body: some View {
        List(law.lawList, id: \.self) { ids  in
            Section(header: Text(LawProvider.shared.getCategoryName(ids[0]))) {
                ForEach(ids, id: \.self) { uuid in
                    NavigationLink(destination: content(uuid: uuid)){
                        Text( LawProvider.shared.getLawNameByUUID(uuid))
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "宪法修正案")
        .onChange(of: searchText){ text in
            law.filterLawList(text: text)
        }
    }
}

struct ContentView: View {
    
    class SheetMananger: ObservableObject{
        
        enum SheetState {
            case none
            case favorite
            case setting
        }
        
        @Published var isShowingSheet = false
        @Published var sheetState: SheetState = .none {
            didSet {
                isShowingSheet = sheetState != .none
            }
        }
    }
    
    @StateObject var sheetManager = SheetMananger()
    
    var body: some View {
        NavigationView{
            LawList()
                .navigationTitle("中国法律")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        IconButton(icon: "heart.text.square") {
                            sheetManager.sheetState = .favorite
                        }
                        IconButton(icon: "gear") {
                            sheetManager.sheetState = .setting
                        }
                    }
                }
                .sheet(isPresented: $sheetManager.isShowingSheet, onDismiss: {
                    sheetManager.sheetState = .none
                }) {
                    NavigationView {
                        if sheetManager.sheetState == .setting {
                            SettingView()
                                .navigationBarTitle("关于", displayMode: .inline)
                        } else if sheetManager.sheetState == .favorite {
                            FavoriteView()
                                .navigationBarTitle("收藏", displayMode: .inline)
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}
