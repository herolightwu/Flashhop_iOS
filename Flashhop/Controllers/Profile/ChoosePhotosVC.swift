//
//  ChoosePhotosVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/28.
//

import UIKit
import Photos

class ChoosePhotosVC: UIViewController {
    public var callback: (([PHAsset]) -> ())?
    
    public var max_count = 7
    private var photos: PHFetchResult<PHAsset>? = nil
    private var nIndex:[Int] = []
    
    @IBOutlet weak var lbChoose: UILabel!
    private var ivPhotos:[UIImageView] = []
    @IBOutlet weak var lbSelected: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if max_count == 1 { lbChoose.text = "Choose a picture" }
        else { lbChoose.text = "Choose 1-\(max_count) pictures" }
        
        lbSelected.text = "0/\(max_count) selected"
        
        // image views to show selected photos
        for tag in 0..<max_count {
            ivPhotos.append(self.view.viewWithTag(20)!.viewWithTag(tag) as! UIImageView)
        }
        
        // collectionView layout
        let w = collectionView.frame.size.width
        let ww = (w - 6) / 4
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: ww, height: ww)
        
        // load all photos
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                fetchOptions.fetchLimit = 100
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
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func reloadImageViews() {
        for imageView in ivPhotos {
            imageView.image = nil
        }
        for i in 0 ..< nIndex.count {
            let photo = photos?.object(at: nIndex[i])
            ivPhotos[i].image = getImage(asset: photo!)
        }
        
        lbSelected.text = "\(nIndex.count)/\(max_count) selected"
    }
    @IBAction func onSave(_ sender: UIButton) {
        var param:[PHAsset] = []
        for i in nIndex {
            param.append((photos?.object(at: i))!)
        }
        
        if param.count > 0 {
            self.navigationController?.popViewController(animated: true)
            callback?(param)
        }
    }
}

extension ChoosePhotosVC: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        let imageView = cell.viewWithTag(10) as! UIImageView
        let checked = cell.viewWithTag(20) as! UIImageView
        let photo = photos?.object(at: indexPath.row)
        imageView.image = getImage(asset: photo!)
        checked.isHidden = !nIndex.contains(indexPath.row)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.photos?.count ?? 0
        return count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if max_count == 1 {
            nIndex = [index]
        }else{
            if nIndex.contains(index) {
                nIndex = nIndex.filter(){$0 != index}
            }else{
                if nIndex.count < max_count {
                    nIndex.append(index)
                }
            }
        }
        collectionView.reloadData()
        reloadImageViews()
    }
}
