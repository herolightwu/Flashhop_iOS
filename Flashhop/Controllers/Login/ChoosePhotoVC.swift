//
//  UploadPhotoVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/16.
//

import UIKit
import Photos
import Alamofire
import KRProgressHUD

class ChoosePhotoVC: UIViewController {
    
    private var photos: PHFetchResult<PHAsset>? = nil
    private var nIndex = -1

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // collectionView layout
        let w = collectionView.frame.size.width
        let ww = (w - 12) / 4
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: ww, height: ww)
        
        // load all photos
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                fetchOptions.fetchLimit = 80
                self.photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            default:
                print("Error")
            }
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func onPrev(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onNext(_ sender: Any) {
        if nIndex != -1 {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewVC") as! PhotoPreviewVC
            vc.photo = photos![nIndex]
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            btnNext.shake()
        }
    }
}

extension ChoosePhotoVC: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        let imageView = cell.viewWithTag(10) as! UIImageView
        let checked = cell.viewWithTag(20) as! UIImageView
        let photo = photos?.object(at: indexPath.row)
        imageView.image = getImage(asset: photo!)
        checked.isHidden = nIndex != indexPath.row
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.photos?.count ?? 0
        return count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        nIndex = indexPath.row
        collectionView.reloadData()
    }
}
