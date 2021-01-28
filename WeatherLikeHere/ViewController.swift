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
import MapKit
import Moya
import ObjectMapper
import Moya_ObjectMapper
import Alamofire



class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var latitudeTF: UILabel!
    @IBOutlet weak var longitudeTF: UILabel!
    @IBOutlet weak var tempTF: UILabel!
    @IBOutlet weak var cityTF: UILabel!
    
    
    
    
    @IBOutlet weak var imageArea: UIImageView!
    
    //let locationManager = CLLocationManager()

    var locationManager:CLLocationManager!
    
    var w: Weather? = nil
    var weatherIsGet = 0;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authUser = authAnonim()
        print("Результат авторизации viewDidLoad: \(authUser)")
        
        //getWeather()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
        
            checkLocationEnabled()
            checkAutorization()
    }

    @IBAction func addPhoto(_ sender: Any) {  //Выбираем фотографию
        locationManager.startUpdatingLocation()
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        //imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
        //savePhoto()
    }

    //Проверяем включена ли на устройстве геолокация
    func checkLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            // Вот тут нужно вызвать функцию или что-то написать, если разрешение на геолокацию есть
            print("Геолокация разрешена")
            //Пробую получить координаты
            locationManager.startUpdatingLocation()
            
        } else {
            let alert = UIAlertController(title: "Отключена функция геолокации", message: "Включить?", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Настройки", style: .default) { (alert) in
                if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func test(){
        var locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()

            if CLLocationManager.locationServicesEnabled(){
                locationManager.startUpdatingLocation()
            }
    }
    
    //Проверяем есть ли у нашего приложения разрешения на получение геолокации
    func checkAutorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            //вот здесь мы понимаем что разрешение есть и можно что-то написать
            print("Разрешение на геолокацию для приложеня есть")
            
            //Пробую получить координаты
            locationManager.startUpdatingLocation()
            
            break
        case .notDetermined:
            print(".notDetermined")
            //Вот здесь мы должны запросить разрешение
            locationManager.requestWhenInUseAuthorization()
            //test()
            break
        case .restricted:
            print(".restricted")
            break
        case .denied:
            print(".denied")
            let alert = UIAlertController(title: "Отсутсвует разрешение на геолокацию", message: "Включить?", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Настройки", style: .default) { (alert) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    //Под вопросом!!!!
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let userLocation:CLLocation = locations[0] as CLLocation

            // Call stopUpdatingLocation() to stop listening for location updates,
            // other wise this function will be called every time when user location changes.

           // manager.stopUpdatingLocation()

            print("user latitude = \(userLocation.coordinate.latitude)")
            latitudeTF.text = String(userLocation.coordinate.latitude)
            print("user longitude = \(userLocation.coordinate.longitude)")
            longitudeTF.text = String(userLocation.coordinate.longitude)
        
            //Получили координаты, теперь можно и погоду запросить если только уже не запрашивали
            if weatherIsGet==0 {
                getWeather()
                weatherIsGet = 1
            }
        
        
        
        
        
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    //Конец под вопросом

    
    
    
    
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
        }
        return true
    } //END
    
    
    func saveData(url: String) -> () {
        //
        
        locationManager.stopUpdatingLocation()
        
        var refbd: DocumentReference? = nil
        let db = Firestore.firestore()
        refbd = db.collection("users").addDocument(data: [
            "longitude": Double(longitudeTF.text!),
            "latitude": Double(latitudeTF.text!),
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


    // MARK 1 - Здесь реализован вызов JSON с помощью Moya
        private func getWeather(){
                
            let provider = MoyaProvider<RequestManager>(plugins:[NetworkLoggerPlugin()])
                
                provider.request(.getWheather) { result in
                    switch result {
                    case .success(let response):
                        //self.refreshControl.endRefreshing()
                        //self.isLoading = false
                        
                        do {
                            try print(response.mapJSON())
                        } catch {
                            print(error)
                        }
                        if let json = (try? response.mapJSON()) as? [String : Any] {
                            let wheather = Mapper<Weather>().map(JSON: json)
                            self.w =  wheather
                            //self.mergeDataSource(specializations: specializations)
                            print("Wheather = \(wheather)")
                            print(wheather?.id ?? "Нету тут ничего")
                            print("Weater.temp", wheather?.weatherMain?.temp ?? "Пусто")
                            let temp = wheather?.weatherMain?.temp ?? 0
                            self.tempTF.text = String("\(temp) C")
                            self.cityTF.text = wheather?.nameCity

                        }
                    case .failure(let error):
                        //self.isLoading = false
                        //self.refreshControl.endRefreshing()
                        print(error.errorDescription ?? "Unknown error")
                    }
                }
            }
        // END MARK 1
}






