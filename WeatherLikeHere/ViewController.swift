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

    
    
    @IBOutlet weak var namePlace: UILabel!
    @IBOutlet weak var latitudeTF: UILabel!
    @IBOutlet weak var longitudeTF: UILabel!
    @IBOutlet weak var tempTF: UILabel!
    @IBOutlet weak var cityTF: UILabel!
    @IBOutlet weak var imageViewIconWeather: UIImageView!
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var imageAreaPicture: UIImageView!
    @IBOutlet weak var viewPlace: UIView!
    @IBOutlet weak var imageArea: UIImageView!
    
    var locationManager:CLLocationManager!
    var w: Weather? = nil //Глобальная перменная для объекта Погоды
    var weatherIsGet = 0; //Эта переменная 0 или 1, говорит о том, что 0 - запрос на погоду не сделал, 1 - сделан
    
    struct Picture{
        var lon: Double?
        var lat: Double?
        var temp: Double?
        var distance: Double?
        var url: String?
        var place: String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authUser = authAnonim()
        print("Результат авторизации viewDidLoad: \(authUser)")
        //getWeather()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainInfoView.layer.cornerRadius = 25
        viewPlace.layer.cornerRadius = 25
        
        viewPlace.isHidden = true
        
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
        //imagePickerController.sourceType = .photoLibrary
        imagePickerController.sourceType = .camera
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
    
//    func test(){
//        var locationManager = CLLocationManager()
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestAlwaysAuthorization()
//
//            if CLLocationManager.locationServicesEnabled(){
//                locationManager.startUpdatingLocation()
//            }
//    }
    
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
    
    //Вот здесь я получаю координаты GPS
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
                getWeather(lat: userLocation.coordinate.latitude, lon: userLocation.coordinate.longitude)
                weatherIsGet = 1
            }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    //Конец "Вот здесь я получаю координа GPS"
   
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
    
    // Здесь записываем в БД данные: координаты, температуру, URL картинки и т.д.
    func saveData(url: String) -> () {
        //
        
        //print("tempTF.text = \(tempTF.text!)")
        let temp = lroundf(Float(w?.weatherMain?.temp ?? 0))
        //let temp = lroundf(Float(wheather?.weatherMain?.temp ?? 0))
        locationManager.stopUpdatingLocation()
        
        var refbd: DocumentReference? = nil
        let db = Firestore.firestore()
        refbd = db.collection("users").addDocument(data: [
            "longitude": Double(longitudeTF.text!),
            "latitude": Double(latitudeTF.text!),
            "Place": cityTF.text,
            "born": 1815,
            "dateExample": Timestamp(date: Date()),
            "temp": temp,
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
                        
                        // Фото записалось, теперь записываем в БД данные по этой картинке
                        self.saveData(url: url.absoluteString)
                    }
                }
            }
        }
    }


    // MARK 1 - Здесь реализован вызов JSON от OpenWeatherMap.com с помощью Moya
    private func getWeather(lat: Double, lon:Double){
                
        let provider = MoyaProvider<RequestManager>(plugins:[NetworkLoggerPlugin()])
                
        provider.request(.getWheather(lat: lat, lon: lon)) { result in
                    switch result {
                    case .success(let response):
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
                            let temp = lroundf(Float(wheather?.weatherMain?.temp ?? 0))
                            self.tempTF.text = String("\(temp) C")
                            self.cityTF.text = wheather?.nameCity
                            
                            guard let weatherIcon = wheather?.weatherWeather?[0].icon else {return} //Обращение идет к первому элементу массива, а в жтом массиве лежит словарь из JSON, поэтому мы не останавливаемся на элементе массива, апродолжаем проваливаться дальше через точку, т.е. [0].ключ из JSON
                            print("WheatherIcon = \(weatherIcon)")
                            self.getIconWeather(partURL: weatherIcon)
                            
                            //Теперь мы знаем погоду и можем запросить картинку с соотвествующей температурой
                            self.fetchPictureWithTemp()
                            
                        }
                    case .failure(let error):
                        print(error.errorDescription ?? "Unknown error")
                    }
                }
            }
        // END MARK 1
    
    
    
    
    //Получаю иконку погоды
    private func getIconWeather(partURL: String) {
        
        guard let url = URL(string: "http://openweathermap.org/img/wn/\(partURL)@2x.png") else {return}
        print("URL = \(url)")
        let session = URLSession.shared
    
        session.dataTask(with: url) { (data, response, error) in
            if let date = data, let image = UIImage(data: date) {
                DispatchQueue.main.async {
                    //self.activitiIndicator.stopAnimating()
                    self.imageViewIconWeather.image = image
                }
            }
        }.resume()
    }
    //Конец иконки погоды
    
    //Делаю запрос к Firebase с целью найти картинку с одинаковой температурой
    private func fetchPictureWithTemp(){
        let db = Firestore.firestore()
        //let allFields = db.collection("users").whereField("temp", isEqualTo: true)
        db.collection("users").getDocuments() { [self] (querySnapshot, err) in
            var newPicture = Picture()
            var PictureIsGet = false
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var equalTemp: Double // Сюда кладем текущую температуру
                equalTemp = self.w?.weatherMain?.temp as! Double
                var tmpPicture = Picture()
                print("equalTemp = \(equalTemp)")
                print("Запускаем главный цикл: перебор по записям")
                print("Количество документов = \(querySnapshot!.documents.count)")
                var i=1
                
                let lon1 = Double(self.longitudeTF.text!)!
                let lat1 = Double(self.latitudeTF.text!)!
                
                
                for document in querySnapshot!.documents {
                    print("Обрабатываем документ номер: \(i)")
                    i += 1
                    
                    //Небольшой рефакторинг. Хочу просто вынуть из элемента массива все ключи, потом если температура соотвествует текущей, сравнить значение дистанции (между текущей точкой и из элемента массива) со значением из объекта newPicture.distance. И если значение больше, то заполнить объект newPicture() новыми значениями из текущего элемента массива.
                    //Сначала вынимаем значения всех ключей
                    for value in document.data() as Dictionary<String, Any> {
                        //print("В цикле value")
                        
                        switch value.key {
                        case "Place":
                            tmpPicture.place = value.value as? String
                        case "latitude":
                            tmpPicture.lat = value.value as? Double
                            //guard var b = tmpPictureLat
                            //print ("b = \(b)")
                        case "longitude":
                            tmpPicture.lon = value.value as? Double
                        case "temp":
                            tmpPicture.temp = value.value as? Double
                        case "url":
                            tmpPicture.url = value.value as? String
                        default:
                            print ("Не нужный ключ из документа")
                        }
                    }
                    guard let tmpLat = tmpPicture.lat else {continue}
                    guard let tmpLon = tmpPicture.lon else {continue}
                   
                    tmpPicture.distance = getDistanceFromLatLonInKm(lat1: lat1, lon1: lon1, lat2: tmpPicture.lat!, lon2: tmpPicture.lon!)
                    print("tmpPicture.distance = \(tmpPicture.distance)")
                    guard let tmpDistance = tmpPicture.distance else {continue}
                  
                    //print("tmpPicture = \(tmpPicture)")
                    //Т.е. мы пробежались по всем элементам словаря из этого элемента массива. Теперь нам нужно перед тем как брать новый элемент массива, сравнить температру из элемента массива с текущей и проверить что дистанция от текущего места до картинки/ Если дистанция больше, то мы значеними из этого эдемент амассива заполняем объект newPicture()
                    
                    //print("шаг 0")
                    
                    if Int(tmpPicture.temp!) == lround(equalTemp) || Int(tmpPicture.temp!) == lround((equalTemp+1)) || Int(tmpPicture.temp!) == lround((equalTemp-1)) {
                        //Итак, мы понимаем, что у нас есть картинка, которая имеет схожую температуру
                        //Если дистанция между текущей точкой и точкой картинки больше или равна 0, то мы пишем значения в конечный объект newPicture()
//                        let lon1 = Double(self.longitudeTF.text!)!
//                        let lat1 = Double(self.latitudeTF.text!)!
                        print("newPicture.distance = \(newPicture.distance)")
                        if tmpDistance >= 0 || getDistanceFromLatLonInKm(lat1: lat1, lon1: lon1, lat2: tmpLat, lon2: tmpLon) > newPicture.distance ?? 0 {
                            
                            let sumDistanceForPrint = "sumDistanceForPrint: дистанция от текущей точки до картинки - " + String(getDistanceFromLatLonInKm(lat1: lat1, lon1: lon1, lat2: tmpLat, lon2: tmpLon)) + " и с чем сравниваем: " + String(newPicture.distance ?? 0)
                            print(sumDistanceForPrint)
                            
                            newPicture.temp = tmpPicture.temp
                            newPicture.lat = tmpPicture.lat
                            newPicture.lon = tmpPicture.lon
                            newPicture.url = tmpPicture.url
                            newPicture.place = tmpPicture.place
                            newPicture.distance = tmpDistance
                            PictureIsGet = true
                        
                            //print (getDistanceFromLatLonInKm(lat1: lat1, lon1: lon1, lat2: tmpPicture.lat!, lon2: tmpPicture.lon!))
                            //print("шаг 0.5/ Это значит что я внутри if со сравнением дистанции")
                        }
                        //print("шаг 1/ Это значит что я внутри if с проверкой температуры")
                    }
                    //print("шаг 2")
                } //Конец цикла где мы перебираем элементы массива (записи из документа)
                //print("шаг 3")
            } //Конец цикла всего среза документов
            
                
            print("Это должна быть последняя запись")
            //Теперь из объекта Picture достаем данные самой дальней картинки
            print("ИТАК:")
            print("URL = \(newPicture.url)")
            print("Temp картинки = \(newPicture.temp)")
            //print("Temp текущий = \(equalTemp)")
            print("Дистанция: \(newPicture.distance)")
                

            //Теперь у нас есть подходящая картика и можно подгрузить url в ImageView
            //А может картинки и нет тогда идем нафиг
            if PictureIsGet {
                getPictureWeather(urlPictures: newPicture.url!, place: newPicture.place!)
            } else {return}
        }
    }
    

    //Получаю картинку с похожей погодой
    private func getPictureWeather(urlPictures: String, place: String) {
        
        guard let url = URL(string: urlPictures) else {return}
        print("URL = \(url)")
        let session = URLSession.shared
    
        session.dataTask(with: url) { (data, response, error) in
            if let date = data, let image = UIImage(data: date) {
                DispatchQueue.main.async {
                    //self.activitiIndicator.stopAnimating()
                    //self.imageViewIconWeather.image = image
                    self.imageAreaPicture.image = image
                    print("place = \(place)")
                    if place != "" {
                        self.namePlace.text = "Эта фотография сделана в месте: \(place)"
                        self.viewPlace.isHidden = false
                    }
                }
            }
        }.resume()
    }
    //Конец картинки с похожей погодой
    
    
    
    // Вычисление расстояния между двумя координатами
    func getDistanceFromLatLonInKm(lat1: Double, lon1: Double, lat2: Double, lon2:Double) -> Double {
        let R:Double = 6371
        let dLat = deg2rad(deg: lat2 - lat1)
        let dLon = deg2rad(deg: lon2 - lon1)
        let a = sin(dLat/2) * sin(dLat/2) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * sin(dLon/2) * sin(dLon/2)

        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = R * c // Distance in km
      return d
    }

    private func deg2rad(deg: Double) -> Double {
        return deg * (.pi/180)
    }
    
    
    @IBAction func typeToHidden(_ sender: UIButton) {
        if mainInfoView.isHidden == true {
            mainInfoView.isHidden = false
            if namePlace.text != "Label" {
                viewPlace.isHidden = false
            }
        } else {
            mainInfoView.isHidden = true
            //namePlace.isHidden = true
            viewPlace.isHidden = true
        }
    }
 
    
}






