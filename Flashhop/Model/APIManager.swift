//
//  APIManager.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/4.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import KRProgressHUD
import Photos
import CoreLocation
import GoogleMaps
import GoogleSignIn

class APIManager {
    static var token = ""
    class func set_token(_ str: String) {
        token = str
        UserDefaults.standard.setValue(str, forKey: "TOKEN")
    }
    class func saved_token() -> String {
        token = UserDefaults.standard.string(forKey: "TOKEN") ?? ""
        return token
    }
    class func headers() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(token)",
        ]
        return headers
    }
    class func loginWithFacebook(_ vc:UIViewController, push_id: String) {
        if let access_token = AccessToken.current {
            let request = GraphRequest(graphPath: "me", parameters: ["fields":"id,email,name,first_name,last_name,picture.type(large)"], tokenString: access_token.tokenString, version: nil, httpMethod: .get)
            KRProgressHUD.show()
            request.start { (connection, result, error) in
                KRProgressHUD.dismiss()
                if let error = error {
                    print(error)
                }else{
                    guard let info = result as? [String: Any] else { return }
                    let email = info["email"] ?? ""
                    let first_name = info["first_name"] ?? ""
                    let last_name = info["last_name"] ?? ""
                    let imageURL = ((info["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String ?? ""
                    let social_id = info["id"] ?? ""
                    
                    let url = "https://flashhop.com/api/registerSocialLogin"
                    let params:Parameters = [
                        "first_name":first_name,
                        "last_name":last_name,
                        "email":email,
                        "push_user_id":push_id,
                        "social_image":imageURL,
                        "social_id":social_id,
                        "social_name":"facebook"
                    ]
                    KRProgressHUD.show()
                    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
                        .responseJSON { (response) in
                            KRProgressHUD.dismiss()
                            if let value = response.result.value as? [String: AnyObject] {
                                if let error = value["error"] {
                                    print(error)
                                }else if let data = value["data"] as? [String: AnyObject] {
                                    let token = data["token"] as! String
                                    set_token(token)
                                    me = FUser(dic: data["user"] as! [String : AnyObject])
                                    
                                    didAuth(vc)
                                }
                            }
                    }
                }
            }
        }
    }
    class func loginWithGoogle(_ user: GIDGoogleUser, push_id: String, _ vc:UIViewController) {
        let givenName = user.profile.givenName!
        let familyName = user.profile.familyName!
        let email = user.profile.email!
        let photo = user.profile.hasImage ? user.profile.imageURL(withDimension: 100)?.absoluteString : ""
        
        let url = "https://flashhop.com/api/registerSocialLogin"
        let params:Parameters = [
            "first_name":givenName,
            "last_name":familyName,
            "email":email,
            "push_user_id":push_id,
            "social_image":photo as Any,
            "social_id":user.userID as Any,
            "social_name":"google"
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let error = value["error"] {
                        print(error)
                    }else if let data = value["data"] as? [String: AnyObject] {
                        let token = data["token"] as! String
                        set_token(token)
                        me = FUser(dic: data["user"] as! [String : AnyObject])
                        
                        didAuth(vc)
                    }
                }
        }
    }
    class func register(email: String, pw: String, first_name: String, last_name: String, push_id: String, result: @escaping ([String: AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        
        me = FUser()
        
        let url = "https://flashhop.com/api/register"
        let params:Parameters = ["email":email, "password":pw, "first_name":first_name, "last_name":last_name, "push_user_id":push_id]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    print(value)
                    if let e = value["error"] {
                        error(e)
                    }else if let data = value["data"] as? [String: AnyObject] {
                        result(data)
                    }
                }
        }
    }
    class func login(email: String, pw: String, push_id: String, result: @escaping ([String: AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        me = FUser()
        
        let url = "https://flashhop.com/api/login"
        let params:Parameters = ["email":email, "password":pw, "push_user_id":push_id]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func checkToken(push_id: String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        me = FUser()
        
        if saved_token() != "" {
            let url = "https://flashhop.com/api/chkToken"
            let params:Parameters = ["push_user_id":push_id]
            KRProgressHUD.show()
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
                .responseJSON { (response) in
                    KRProgressHUD.dismiss()
                    if let value = response.result.value as? [String: AnyObject] {
                        if let e = value["error"] {
                            error(e)
                        }else{
                            result(value)
                        }
                    }
            }
        }else{
            error(["code":1000] as AnyObject) // no saved token
        }
    }
    class func didAuth(_ vc: UIViewController) {
        if me.email_verified == false {
            let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let vc2 = storyboard.instantiateViewController(withIdentifier: "VerifyVC")
            vc.navigationController?.pushViewController(vc2, animated: true)
        }else{
            if me.dob == "" {
                let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                let vc2 = storyboard.instantiateViewController(withIdentifier: "WelcomeVC")
                vc.navigationController?.setViewControllers([vc2], animated: false)
            }else{
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc2 = storyboard.instantiateInitialViewController()
                UIApplication.shared.delegate!.window!!.rootViewController = vc2
                //vc.present(vc2!, animated: true, completion: nil)
            }
        }
    }
    class func verifyEmail(code:String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/emailVerify"
        let params:Parameters = ["code":code]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func sendVerifyCode(result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/sendVerifyCode"
        let params:Parameters = ["email":me.email]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func registerUserProfile(photo: PHAsset, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/registerUserProfile"
        let params = [
            "lang":me.langs_string(),
            "gender":me.gender.str,
            "interests":me.interest_str(),
            "dob":me.dob
        ]
        KRProgressHUD.show()
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let data = getImage(asset: photo).resizedTo1MB()!.pngData() {
                multipartFormData.append(data, withName: "photo_id", fileName: "\(Date().timeIntervalSince1970).png", mimeType: "image/png")
            }
            for (key, value) in params {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: url,
           method:.post,
           headers:headers(),
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    KRProgressHUD.dismiss()
                    if let value = response.result.value as? [String: AnyObject] {
                        if let e = value["error"] {
                            error(e)
                        }else{
                            result(value)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
            
        })
    }
    class func changeNotificationSettings(bMyActivities:Bool, bFriendsActivities:Bool, bChats: Bool, result: @escaping ([String: AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/changeNotificationSetting"
        let params = [
            "push_my_activities":bMyActivities,
            "push_friends_activities":bFriendsActivities,
            "push_chats":bChats
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func changePrivacy(bHideAge:Bool, bHideLocation: Bool, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/changePrivacy"
        let params = [
            "hide_my_age": bHideAge,
            "hide_my_location": bHideLocation
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func changeEmailRequest(email:String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/emailResetRequest"
        let params = [
            "email": email
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func changeEmail(email:String, code:String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/changeEmail"
        let params:Parameters = [
            "email": email,
            "code": code
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func changePassword(pw:String, new_pw:String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/changePassword"
        let params:Parameters = [
            "old_pwd": pw,
            "new_pwd": new_pw,
            "email": me.email
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func changeInterests(interests: String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/changeInterests"
        let params:Parameters = [
            "interests": interests
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func changeLangs(langs:String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/changeLang"
        let params:Parameters = [
            "lang": langs
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func updateUserProfile(params:Parameters, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/updateUserProfile"
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func updateUserProfile(photos:[PHAsset], user:FUser, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/updateUserProfile"
        let params = [
            "personality_type":user.personality_type,
            "fun_facts":user.fun_facts
        ]
        KRProgressHUD.show()
        Alamofire.upload(multipartFormData: { multipartFormData in
            var i = 0
            for photo in photos {
                if let data = getImage(asset: photo).resizedTo1MB()!.pngData() {
                    multipartFormData.append(data, withName: "image\(i)", fileName: "\(Date().timeIntervalSince1970)_\(i).png", mimeType: "image/png")
                    i += 1
                }
            }
            for (key, value) in params {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: url,
           method:.post,
           headers:headers(),
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    KRProgressHUD.dismiss()
                    if let value = response.result.value as? [String: AnyObject] {
                        if let e = value["error"] {
                            error(e)
                        }else{
                            result(value)
                        }
                    }
                }
            case .failure(let error):
                KRProgressHUD.dismiss()
                print(error)
            }
        })
    }
    
    class func getPaymentTransactions(timestamp:String, uid:String, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/getTransferList"
        let params:Parameters = [
            "user_id": uid,
            "date_timestamp": timestamp
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    
    class func uploadVoiceFile(filename:URL, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/uploadFile"
        KRProgressHUD.show()
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let soundData = NSData(contentsOf: filename) {
                multipartFormData.append(soundData as Data, withName:"file", fileName: "\(Int(Date().timeIntervalSince1970)).m4a", mimeType: "audio/m4a")
            }
        }, to: url,
           method:.post,
           headers:headers(),
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    KRProgressHUD.dismiss()
                    if let value = response.result.value as? [String: AnyObject] {
                        if let e = value["error"] {
                            error(e)
                        }else{
                            result(value)
                        }
                    }
                }
            case .failure(let error):
                KRProgressHUD.dismiss()
                print(error)
            }
        })
    }
    
    class func filterEvents(result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/filter"
        //KRProgressHUD.show()
        let params = me.filter.dic_value()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                //KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func hostEvent(image:UIImage, event:Event, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/hostEvent"
        let params = event.dic_value()
        KRProgressHUD.show()
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let data = image.resizedTo1MB()!.pngData() {
                multipartFormData.append(data, withName: "cover_photo", fileName: "\(Date().timeIntervalSince1970).png", mimeType: "image/png")
            }
            for (key, value) in params {
                multipartFormData.append(("\(value)").data(using: .utf8)!, withName: key)
            }
        }, to: url,
           method:.post,
           headers:headers(),
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    KRProgressHUD.dismiss()
                    if let value = response.result.value as? [String: AnyObject] {
                        if let e = value["error"] {
                            error(e)
                        }else{
                            result(value)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }            
        })
    }
    class func hostEvent( event: Event, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/hostEvent"
        let params = event.dic_value()
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func editEvent(image:UIImage, event:Event, result:@escaping ([String:AnyObject])->Void, error:@escaping(AnyObject)->Void) {
        let url = "https://flashhop.com/api/editEvent"
        var params = event.dic_value()
        params["event_id"] = "\(event.id)"
        KRProgressHUD.show()
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let data = image.resizedTo1MB()!.pngData() {
                multipartFormData.append(data, withName: "cover_photo", fileName: "\(Date().timeIntervalSince1970).png", mimeType: "image/png")
            }
            for (key, value) in params {
                multipartFormData.append(("\(value)").data(using: .utf8)!, withName: key)
            }
        }, to: url,
           method:.post,
           headers:headers(),
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    KRProgressHUD.dismiss()
                    if let value = response.result.value as? [String: AnyObject] {
                        if let e = value["error"] {
                            error(e)
                        }else{
                            result(value)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    class func editEvent( event: Event, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/editEvent"
        var params = event.dic_value()
        params["event_id"] = "\(event.id)"
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func pinLocation(address:String, lat:Double, lng:Double) {
        me.address = address
        me.lat = lat
        me.lng = lng
        
        let url = "https://flashhop.com/api/pinUserLocation"
        let params:Parameters = [
            "address": address,
            "lat": lat,
            "lng": lng
        ]
        //KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                //KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }
                }
        }
    }
    class func getAddress(lat:Double, lng:Double, callback: ((String)->Void)?) {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lng)&key=\(GOOGLE_API_KEY)"
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                let responseJson = response.result.value! as! NSDictionary
                if let results = responseJson.object(forKey: "results")! as? [NSDictionary] {
                    if results.count > 0 {
                        if let address = results[0]["formatted_address"] as? String {
                            callback?(address)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    class func updateUserLocation(lat:Double, lng:Double, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/updateUserLocation"
        let params:Parameters = [
            "lat": lat,
            "lng": lng
        ]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func joinEvent(event_id:Int, is_invited:Bool, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/joinEvent"
        let params:Parameters = [
            "event_id": event_id,
            "is_invited": is_invited
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func leaveEvent(event_id:Int, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/leaveEvent"
        let params:Parameters = [
            "event_id": event_id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func addFriend(user_id:Int, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/addToMyFriend"
        let params:Parameters = [
            "friend_id": user_id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func inviteFriends(user_ids:[Int], event_id: Int, result:@escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        var str = ""
        for user_id in user_ids {
            str += "\(user_id)" + ","
        }
        if str.count != 0 { str = String(str.dropLast()) }
        
        let url = "https://flashhop.com/api/inviteFriends"
        let params:Parameters = [
            "user_id_list": str,
            "event_id":event_id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func eventLikeDislike(event_id:Int, is_liked:Int, result:@escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/eventLikeDislike"
        let params:Parameters = [
            "event_id": event_id,
            "is_liked": is_liked
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func getAllFriends(result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/getAllFriends"
        let params:Parameters = [
            "user_id": me.id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func insert_tag(user_id:Int, tag:String, result: @escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/insert_tag"
        let params:Parameters = [
            "user_id": user_id,
            "tags": tag,
            "tager_id": me.id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func removeFromMyFriend(friend_id: Int, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/removeFromMyFriend"
        let params:Parameters = [
            "friend_id": friend_id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func report(content:String, category:String, id:Int, result: @escaping ([String:AnyObject])->Void, error: @escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/report"
        let params:Parameters = [
            "content": content,
            "category": category,
            "tbl_id": id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func getUpcomingEvents(callback:@escaping ([Event])->Void) {
        let url = "https://flashhop.com/api/getUpcomingEvents"
        let params:Parameters = ["current_time":Date().timeIntervalSince1970]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                var events:[Event] = []
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }else{
                        if let dicArray = value["data"] as? [[String:AnyObject]] {
                            for dic in dicArray {
                                let event = Event(dic: dic)
                                events.append(event)
                            }
                        }
                    }
                }
                callback(events)
        }
    }
    
    class func getChatGroupEvents(callback:@escaping ([Event])->Void) {
        let url = "https://flashhop.com/api/getUpcomingEvents"
        let params:Parameters = ["current_time":Date().timeIntervalSince1970,
                                 "before_days":"7"]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                var events:[Event] = []
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }else{
                        if let dicArray = value["data"] as? [[String:AnyObject]] {
                            for dic in dicArray {
                                let event = Event(dic: dic)
                                events.append(event)
                            }
                        }
                    }
                }
                callback(events)
        }
    }
    
    class func sendChatNotification(ev_id: String, msg: String, uid: String, callback:@escaping (Bool)->Void) {
        let url = "https://flashhop.com/api/sendChatPush"
        let params:Parameters = ["event_id": ev_id,
                                 "content": msg,
                                 "sender_id": uid]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                        callback(false)
                    }else{
                        callback(true)
                    }
                }
        }
    }
    
    class func readEvent(event_id: String, callback:@escaping (Int, [Hopper])->Void) {
        let url = "https://flashhop.com/api/readEvent"
        let params:Parameters = ["event_id":event_id]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                var hoppers:[Hopper] = []
                var chat_mute = 0
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }else{
                        if let data = value["data"] as? [String:AnyObject] {
                            chat_mute = data["chat_mute"] as! Int
                            if let creator = data["creator"] as? [String:AnyObject] {
                                let create_user = Hopper(dic: creator)
                                hoppers.append(create_user)
                            }
                            if let members = data["members"] as? [[String:AnyObject]] {
                                for member in members {
                                    let user = member["user"] as! [String:AnyObject]
                                    let one = Hopper(dic: user)
                                    
                                    one.nPaid = member["paid"] as! Int
                                    one.nOffline = member["is_offline_paid"] as! Int
                                    hoppers.append(one)
                                }
                            }
                        }
                        
                    }
                }
                callback(chat_mute, hoppers)
        }
    }
    class func chatMuteEvent(event_id: String, is_muted: String, callback:@escaping (Bool)->Void) {
        let url = "https://flashhop.com/api/chatMuteEvent"
        let params:Parameters = ["event_id":event_id, "is_muted":is_muted]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }else{
                        if let success = value["success"] as? Int {
                            if success == 1 {
                                callback(true)
                            } else {
                                callback(false)
                            }
                        }
                    }
                }
                callback(false)
        }
    }
    class func cancelEvent(event_id: Int, callback: @escaping (Bool)->Void) {
        let url = "https://flashhop.com/api/cancelEvent"
        let params:Parameters = [
            "event_id": event_id
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                        callback(false)
                    }else{
                        callback(true)
                    }
                }
        }
    }
    class func hangouts(user_id:Int, callback:@escaping ([Hangout])->Void) {
        let url = "https://flashhop.com/api/hangouts"
        let params:Parameters = ["user_id":user_id]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                var hangouts:[Hangout] = []
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }else{
                        if let heartArray = value["data"]?["heart"] as? [[String:AnyObject]] {
                            for dic in heartArray {
                                if let user_dic = dic["user"] as? [String:AnyObject] {
                                    let h = Hangout(dic: user_dic)
                                    h.type = "heart"
                                    h.count = dic["count"] as! Int
                                    if h.count > 0 {
                                        hangouts.append(h)
                                    }
                                }
                            }
                        }
                        if let hangoutArray = value["data"]?["hangout"] as? [[String:AnyObject]] {
                            for dic in hangoutArray {
                                if let user_dic = dic["user"] as? [String:AnyObject] {
                                    let h = Hangout(dic: user_dic)
                                    h.type = "hangout"
                                    h.count = dic["count"] as! Int
                                    if h.count > 0 {
                                        hangouts.append(h)
                                    }
                                }
                            }
                        }
                        if let poopArray = value["data"]?["poop"] as? [[String:AnyObject]] {
                            for dic in poopArray {
                                if let user_dic = dic["user"] as? [String:AnyObject] {
                                    let h = Hangout(dic: user_dic)
                                    h.type = "poop"
                                    h.count = dic["count"] as! Int
                                    if h.count > 0 {
                                        hangouts.append(h)
                                    }
                                }
                            }
                        }
                    }
                }
                callback(hangouts)
        }
    }
    class func getWhatsUpFriends(user_id:Int, callback: @escaping ([Alarm],[Alarm],[Alarm])->Void) {
        let url = "https://flashhop.com/api/getWhatsUpFriends"
        let params:Parameters = ["user_id":user_id]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                var todayAlarms:[Alarm] = []
                var yesterdayAlarms:[Alarm] = []
                var last7Alarms:[Alarm] = []
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }else{
                        if let todayArray = value["data"]?["today"] as? [[String:AnyObject]] {
                            for dic in todayArray {
                                let alarm = Alarm(friend_dic: dic)
                                if alarm.desc.count > 5 {
                                    todayAlarms.append(alarm)
                                }
                                
                            }
                        }
                        if let yesterdayArray = value["data"]?["yesterday"] as? [[String:AnyObject]] {
                            for dic in yesterdayArray {
                                let alarm = Alarm(friend_dic: dic)
                                if alarm.desc.count > 5 {
                                    yesterdayAlarms.append(alarm)
                                }
                            }
                        }
                        if let last7Array = value["data"]?["last7"] as? [[String:AnyObject]] {
                            for dic in last7Array {
                                let alarm = Alarm(friend_dic: dic)
                                if alarm.desc.count > 5 {
                                    last7Alarms.append(alarm)
                                }
                            }
                        }
                    }
                }
                callback(todayAlarms, yesterdayAlarms, last7Alarms)
        }
    }
    class func getWhatsUpForMe(user_id: Int, callback: @escaping ([Alarm], [Alarm])->Void) {
        let url = "https://flashhop.com/api/getWhatsUpForMe"
        let params:Parameters = ["user_id":user_id]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                var newAlarms:[Alarm] = []
                var earlierAlarms:[Alarm] = []
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                    }else{
                        if let newArray = value["data"]?["last"] as? [[String:AnyObject]] {
                            for dic in newArray {
                                let alarm = Alarm(me_dic: dic)
                                newAlarms.append(alarm)
                            }
                        }
                        if let earlierArray = value["data"]?["earlier"] as? [[String:AnyObject]] {
                            for dic in earlierArray {
                                let alarm = Alarm(me_dic: dic)
                                earlierAlarms.append(alarm)
                            }
                        }
                    }
                }
                callback(newAlarms, earlierAlarms)
        }
    }
    class func acceptRejectFriendRequest(whatsup_id:String, responser_id:String, requester_id:String, is_accept:String, result:@escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/acceptRejectFriendRequest"
        let params:Parameters = [
            "whatsup_id": whatsup_id,
            "responser_id": responser_id,
            "requester_id": requester_id,
            "is_accept": is_accept,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func likeDisslike(receiver_id:String, islike:String, result:@escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/likeDisLike"
        let params:Parameters = [
            "is_liked": islike,
            "receiver_id": receiver_id,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    
    class func responseSuperLike(whatsup_id:String, reply:String, result:@escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/responseSuperLike"
        let params:Parameters = [
            "whatsup_id": whatsup_id,
            "reply": reply,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func responseSuperDiss(whatsup_id:String, reply:String, result:@escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/responseSuperDiss"
        let params:Parameters = [
            "whatsup_id": whatsup_id,
            "reply": reply,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func updatePaidStatus(user_id:String, event_id:String, paid:String, is_offline_paid: String, result:@escaping ([String:AnyObject])->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/updatePaidStatus"
        let params:Parameters = [
            "user_id": user_id,
            "event_id": event_id,
            "paid": paid,
            "is_offline_paid": is_offline_paid,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    }else{
                        result(value)
                    }
                }
        }
    }
    class func getDebitCheck(user_id: Int, callback: @escaping ([Card])->Void) {
        let url = "https://flashhop.com/api/getDebitCardData"
        let params:Parameters = ["user_id":user_id]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                        callback([])
                    }else{
                        if let success = value["success"] as? Int {
                            if success == 1 {
                                let data = value["data"] as! [String:AnyObject]
                                let card = Card(dic: data)
                                callback([card])
                            } else {
                                callback([])
                            }
                        }
                    }
                }
        }
    }
    class func getDebitCardData(user_id: Int, callback: @escaping ([Card])->Void) {
        let url = "https://flashhop.com/api/getDebitCardData"
        let params:Parameters = ["user_id":user_id]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        print(e)
                        callback([])
                    }else{
                        if let success = value["success"] as? Int {
                            if success == 1 {
                                let data = value["data"] as! [String:AnyObject]
                                let card = Card(dic: data)
                                callback([card])
                            } else {
                                callback([])
                            }
                        }
                    }
                }
        }
    }
    class func updateCustomAccount(user_id:String, card:Card, result:@escaping (Bool)->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/updateCustomAccount"
        let params:Parameters = [
            "user_id": user_id,
            "card_number": card.card_number,
            "holder_name": card.holder_name,
            "exp_month": card.exp_month,
            "exp_year": card.exp_year,
            "card_cvc": card.card_cvc,
            "address_line1": card.address_line1,
            "address_city": card.address_city,
            "address_state": card.address_state,
            "address_postal_code": card.address_postal_code,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    } else {
                        if let success = value["success"] as? Int {
                            if success == 1 {
                                result(true)
                            } else {
                                result(false)
                            }
                        }
                    }
                }
        }
    }
    class func payWithStripeAPI(event:Event, card:Card, result:@escaping (Bool)->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/payWithStripeAPI"
        let params:Parameters = [
            "event_id": event.id,
            "action": "join_event",
            "amount": event.price,
            "currency": event.currency.str.lowercased(),
            "card_number": card.card_number,
            "exp_month": card.exp_month,
            "exp_year": card.exp_year,
            "card_cvc": card.card_cvc,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    } else {
                        if let success = value["success"] as? Int {
                            if success == 1 {
                                result(true)
                            } else {
                                result(false)
                            }
                        }
                    }
                }
        }
    }
    
    class func payTipWithStripeAPI(amount:String, uid: String, card:Card, result:@escaping (Bool)->Void, error:@escaping (AnyObject)->Void) {
        let url = "https://flashhop.com/api/payWithStripeAPI"
        let params:Parameters = [
            "receiver_id": uid,
            "action": "tip",
            "amount": amount,
            "currency": "usd",
            "card_number": card.card_number,
            "exp_month": card.exp_month,
            "exp_year": card.exp_year,
            "card_cvc": card.card_cvc,
        ]
        KRProgressHUD.show()
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { (response) in
                KRProgressHUD.dismiss()
                if let value = response.result.value as? [String: AnyObject] {
                    if let e = value["error"] {
                        error(e)
                    } else {
                        if let success = value["success"] as? Int {
                            if success == 1 {
                                result(true)
                            } else {
                                result(false)
                            }
                        }
                    }
                }
        }
    }
}
