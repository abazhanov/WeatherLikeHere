//
//  ViewController.swift
//  WeatherLikeHere
//
//  Created by Artem Bazhanov on 02.01.2021.
//

import UIKit
import Firebase


class ViewController: UIViewController {

    @IBOutlet weak var imageArea: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authUser = authAnonim()
        
        
    }


    @IBAction func addPhoto(_ sender: Any) {  //Выбираем фотографию
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        //imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
        savePhoto()
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
            
            var ref: DocumentReference? = nil
            let db = Firestore.firestore()
            ref = db.collection("users").addDocument(data: [
                "first": "Ada",
                "last": "Lovelace",
                "born": 1815
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            
            
            
            
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
    }
    

} //END MAIN CLASS


// MARK: - UIImagePickerControllerDelegate
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        //photoImageView.image = image
        imageArea.image = image
    }
}
