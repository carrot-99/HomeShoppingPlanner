//  MemoDetailView.swift

import SwiftUI
import FirebaseStorage

struct MemoDetailView: View {
    @Binding var memo: Memo
    @State private var note: String = ""
//    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @ObservedObject var viewModel: HomeViewModel
    
//    func uploadImageAndUpdateMemo() {
//        guard let inputImage = inputImage else { return }
//        if viewModel.isAuthenticated {
//            // 認証されている場合は、Firebase Storageに画像をアップロード
//            uploadImageToStorage(inputImage) { url in
//                guard let url = url else { return }
//                if let imageData = inputImage.jpegData(compressionQuality: 0.75) {
//                    // FirebaseとCoreDataの両方に画像を保存
//                    viewModel.updateMemoWithImage(storeId: self.memo.storeId, memoId: self.memo.id, imageURL: url, imageData: imageData)
//                }
//            }
//        } else {
//            // 未認証の場合は、CoreDataに画像データを保存
//            if let imageData = inputImage.jpegData(compressionQuality: 0.75) {
//                var updatedMemo = memo
//                updatedMemo.imageData = imageData
//                viewModel.updateMemo(storeId: memo.storeId, memoId: memo.id, updatedMemo: updatedMemo)
//            }
//        }
//    }
    
//    func uploadImageToStorage(_ image: UIImage, completion: @escaping (_ url: String?) -> Void) {
//        // 画像をデータに変換
//        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
//            completion(nil)
//            return
//        }
//
//        // 一意のファイル名を生成
//        let imageName = UUID().uuidString + ".jpg"
//        let storageRef = Storage.storage().reference().child("images/\(imageName)")
//
//        // 画像をアップロード
//        storageRef.putData(imageData, metadata: nil) { metadata, error in
//            guard error == nil else {
//                print("Failed to upload image: \(error!.localizedDescription)")
//                completion(nil)
//                return
//            }
//
//            storageRef.downloadURL { url, error in
//                guard let downloadURL = url else {
//                    print("Download URL not found")
//                    completion(nil)
//                    return
//                }
//                completion(downloadURL.absoluteString)
//            }
//        }
//    }
    
    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                // 品名
                TextField("品名", text: $memo.name)
                
                // 数量
                Stepper("数量: \(memo.quantity)", value: $memo.quantity, in: 1...100)
                
                // 単位
                Picker("単位", selection: $memo.unit) {
                    ForEach(viewModel.units, id: \.self) { unit in
                        Text(unit)
                    }
                }
                
                // 必要時期
                DatePicker("必要時期", selection: $memo.needBy, displayedComponents: .date)
                
                // 優先度
                Picker("優先度", selection: $memo.priority) {
                    Text("高").tag("高")
                    Text("中").tag("中")
                    Text("低").tag("低")
                }
                
                // 購入済み
                Toggle(isOn: $memo.isPurchased) {
                    Text("購入済み")
                }
            }

            Section(header: Text("追加情報")) {
                // カテゴリ
                Picker("カテゴリ", selection: $memo.category) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category)
                    }
                }
                
                // メモ
                TextField("メモ", text: $note)
            }
            
            // 画像
//            Section(header: Text("画像")) {
//                if let imageURL = memo.imageURL, let url = URL(string: imageURL) {
//                    AsyncImage(url: url) { image in
//                        image.resizable().scaledToFit()
//                    } placeholder: {
//                        ProgressView()
//                    }
//                } else if let imageData = memo.imageData, let uiImage = UIImage(data: imageData) {
//                    Image(uiImage: uiImage).resizable().scaledToFit()
//                }
//                Button("画像をアップロード") {
//                    showingImagePicker = true
//                }
//            }
        }
//        .sheet(isPresented: $showingImagePicker, onDismiss: uploadImageAndUpdateMemo) {
//            ImagePicker(image: self.$inputImage)
//        }
        .navigationBarTitle("メモの詳細", displayMode: .inline)
        .onAppear {
            note = memo.note ?? ""
        }
        .onDisappear {
            memo.note = note.isEmpty ? nil : note
            viewModel.updateMemo(storeId: memo.storeId, memoId: memo.id, updatedMemo: memo)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        memo.imageData = inputImage.jpegData(compressionQuality: 1.0)
    }
}
