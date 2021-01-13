//
//  ViewController.swift
//  WeatherLikeHere
//
//  Created by Artem Bazhanov on 02.01.2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage




class ViewController: UIViewController {

    @IBOutlet weak var imageArea: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authUser = authAnonim()
        print("Результат авторизации viewDidLoad: \(authUser)")
    
    }

    @IBAction func addPhoto(_ sender: Any) {  //Выбираем фотографию
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        //imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
        //savePhoto()
    }
    
    func authAnonim() -> String {
        let uid = ""
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                print("Результата авторизации нет!")
                return
            }
            print("Результат авторизации: \(authResult!)")
            DispatchQueue.main.async {
                guard let user = authResult?.user else { return }
                let isAnonymous = user.isAnonymous  // true
                let uid = user.uid
                print("Результат авторизации 2: \(uid)")
            }
        }
        print("Конец функции и uid = \(uid)")
        return uid
    }//END func authAnonim()
    
    func savePhoto() -> Bool {
        
        // Сначала нужно авторизоваться и уже внутри замыкания авторизации делать запись в БД
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                print("Результата авторизации нет!")
                return
            }
            print("Результат авторизации: \(authResult!)")
            
            
            if Auth.auth().currentUser != nil {
              // User is signed in.
              // ...
                print("currentUser = \(Auth.auth().currentUser)")
            } else {
              // No user is signed in.
              // ...
                print("currentUser = :(")
            }
            
            
            
            
            
        
            
            
            
            
            
           //Вот теперь пытаемся записть в БД
            
//            var ref: DocumentReference? = nil
//            let db = Firestore.firestore()
//            ref = db.collection("users").addDocument(data: [
//                "first": "Ada",
//                "last": "Lovelace",
//                "born": 1815
//            ]) { err in
//                if let err = err {
//                    print("Error adding document: \(err)")
//                } else {
//                    print("Document added with ID: \(ref!.documentID)")
//                }
//            }””
            
            
            
            
            
            
            
            
//            DispatchQueue.main.async {
//                guard let user = authResult?.user else { return }
//                let isAnonymous = user.isAnonymous  // true
//                let uid = user.uid
//                print("Результат авторизации 2: \(uid)")
//            }
        
        
        
        }
        
        
        
        
        
        
//        var ref: DocumentReference? = nil
//        let db = Firestore.firestore()
//        ref = db.collection("users").addDocument(data: [
//            "first": "Ada",
//            "last": "Lovelace",
//            "born": 1815
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }

        
        return true
    } //END
    
    
    func saveData(url: String) -> () {
        //
        var refbd: DocumentReference? = nil
        let db = Firestore.firestore()
        refbd = db.collection("users").addDocument(data: [
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815,
            "dateExample": Timestamp(date: Date()),
            "url": url
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(refbd!.documentID)")
            }
        }
    }
    

    
    
    
    
    

} //END MAIN CLASS

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        //photoImageView.image = image
        imageArea.image = image
        
        
        //Попытка записать картинку в БД
        //Проверяем авторизацию
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                print("Проверка авторизации после добавления картинки сработала")
                let userID = Auth.auth().currentUser!.uid
                print("userID = \(userID)")
                
                // using current date and time as an example
                let someDate = Date()
                // convert Date to TimeInterval (typealias for Double)
                let timeInterval = someDate.timeIntervalSince1970
                // convert to Integer
                let myInt = Int(timeInterval)
                
                var fileNameImage:String
                fileNameImage = "-RND-" + String(Int.random(in: 0...100))
                fileNameImage = fileNameImage + "-DATE-" + String(myInt)
                 
                let ref = Storage.storage().reference().child("photos").child("UID-" + userID + String(fileNameImage)) //По сути дела, здесь указываем путь и конечное имя файла. Сейчас оно совпадает с uid пользователя, поэтому будет каждый раз перезаписываться
     
                guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
                
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                ref.putData(imageData, metadata: metadata) { (metadata, error) in
                    guard let _ = metadata else {
                        //completion(.failure(error!))
                        print("Что-то пошло не так с метадатой")
                        return
                    }
                    ref.downloadURL { (url, error) in
                        guard let url = url else {
                            //completion(.failure(error!))
                            print("Ошибка записи картинки")
                            return
                        }
                        //completion(.success(url))
                        print("Картинка записалась. URL: \(url.absoluteString)")
                        self.saveData(url: url.absoluteString)
                        
                        
                    }
                }
                
                
                 
               
                 
                
                
                
                
                
            }
        }
        
    }
}
