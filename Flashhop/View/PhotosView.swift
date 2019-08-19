//
//  PhotosView.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/28.
//

import UIKit
import Photos
import SDWebImage
import KRProgressHUD

class PhotosView: UIView {
    let MAX_COUNT = 7
    let SP:CGFloat = 4  // cell space
    private var ivPhotos:[UIImageView] = []

    func set_photos(photos: [PHAsset]) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        assert(photos.count <= MAX_COUNT, "We can't show \(photos.count) images!")
        
        var images: [UIImage] = []
        for photo in photos {
            let image = getImage(asset: photo)
            images.append(image)
        }
        
        show(images: images)
    }
    func set_photos(urls: [String]) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        assert(urls.count <= MAX_COUNT, "We can't show \(urls.count) images!")
        
        var images: [UIImage] = []
        if urls.count != 0 { KRProgressHUD.show() }
        var n = 0
        for url in urls {
            SDWebImageDownloader.shared.downloadImage(with: URL(string: url)) { (image, data, error, result) in
                if let image = image {
                    images.append(image)
                }
                n += 1
                if n == urls.count {
                    KRProgressHUD.dismiss()
                    self.show(images: images)
                }
            }
        }
    }
    
    private func show(images: [UIImage]) {
        let count = images.count
        switch count {
        case 0:
            break;
        case 1:
            showOne(image: images[0])
            break;
        case 2:
            showTwo(images: images)
            break;
        case 3:
            showThree(images: images)
            break;
        case 4:
            showFour(images: images)
            break;
        case 5:
            showFive(images: images)
            break;
        case 6:
            showSix(images: images)
            break;
        case 7:
            showSeven(images: images)
            break;
        default:
            print("invalid case")
            break;
        }
    }
    private func showOne(image: UIImage) {
        let w = self.frame.size.width
        let h = self.frame.size.height
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = image
        self.addSubview(iv)
    }
    private func showTwo(images: [UIImage]) {
        let w = (self.frame.size.width - SP) / 2
        let h = self.frame.size.height
        for i in 0 ..< images.count {
            let iv = UIImageView()
            switch i {
            case 0:
                iv.frame = CGRect(x: 0, y: 0, width: w, height: h)
                break
            case 1:
                iv.frame = CGRect(x: w + SP, y: 0, width: w, height: h)
                break
            default:
                print("invalid value")
                break
            }
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.image = images[i]
            self.addSubview(iv)
        }
    }
    private func showThree(images:[UIImage]) {
        let w = (self.frame.size.width - SP) / 2
        let h = (self.frame.size.height - SP) / 2
        for i in 0 ..< images.count {
            let iv = UIImageView()
            switch i {
            case 0:
                iv.frame = CGRect(x: 0, y: 0, width: w, height: 2*h)
                break
            case 1:
                iv.frame = CGRect(x: w+SP, y: 0, width: w, height: h)
                break
            case 2:
                iv.frame = CGRect(x: w+SP, y: h+SP, width: w, height: h)
                break
            default:
                print("invalid value")
                break
            }
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.image = images[i]
            self.addSubview(iv)
        }
    }
    private func showFour(images:[UIImage]) {
        let w = self.frame.size.width
        let h = self.frame.size.height
        let w1 = (w - SP) * 0.6
        let h1 = h
        let w2 = (w - SP) * 0.4
        let h2 = (h - 2 * SP) / 3
        for i in 0 ..< images.count {
            let iv = UIImageView()
            switch i {
            case 0:
                iv.frame = CGRect(x: 0, y: 0, width: w1, height: h1)
                break
            case 1:
                iv.frame = CGRect(x: w1+SP, y: 0, width: w2, height: h2)
                break
            case 2:
                iv.frame = CGRect(x: w1+SP, y: h2+SP, width: w2, height: h2)
                break
            case 3:
                iv.frame = CGRect(x: w1+SP, y: 2*(h2+SP), width: w2, height: h2)
                break
            default:
                print("invalid value")
                break
            }
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.image = images[i]
            self.addSubview(iv)
        }
    }
    private func showFive(images:[UIImage]) {
        let w = self.frame.size.width
        let h = self.frame.size.height
        let w1 = (w - SP) * 0.6
        let h1 = (h - SP) / 2
        let w2 = (w - SP) * 0.4
        let h2 = (h - 2 * SP) / 3
        for i in 0 ..< images.count {
            let iv = UIImageView()
            switch i {
            case 0:
                iv.frame = CGRect(x: 0, y: 0, width: w1, height: h1)
                break
            case 1:
                iv.frame = CGRect(x: 0, y: h1+SP, width: w1, height: h1)
                break
            case 2:
                iv.frame = CGRect(x: w1+SP, y: 0, width: w2, height: h2)
                break
            case 3:
                iv.frame = CGRect(x: w1+SP, y: h2+SP, width: w2, height: h2)
                break
            case 4:
                iv.frame = CGRect(x: w1+SP, y: 2*(h2+SP), width: w2, height: h2)
                break
            default:
                print("invalid value")
                break
            }
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.image = images[i]
            self.addSubview(iv)
        }
    }
    private func showSix(images:[UIImage]) {
        let w = self.frame.size.width
        let h = self.frame.size.height
        let w1 = (w - SP) * 0.6
        let h1 = (h - SP) / 2
        let w2 = (w - SP) * 0.4
        let h2 = (h - 2 * SP) / 3
        for i in 0 ..< images.count {
            let iv = UIImageView()
            switch i {
            case 0:
                iv.frame = CGRect(x: 0, y: 0, width: w1, height: h1)
                break
            case 1:
                iv.frame = CGRect(x: 0, y: h1+SP, width: (w1-SP)/2, height: h1)
                break
            case 2:
                iv.frame = CGRect(x: (w1+SP)/2, y: h1+SP, width: (w1-SP)/2, height: h1)
                break
            case 3:
                iv.frame = CGRect(x: w1+SP, y: 0, width: w2, height: h2)
                break
            case 4:
                iv.frame = CGRect(x: w1+SP, y: h2+SP, width: w2, height: h2)
                break
            case 5:
                iv.frame = CGRect(x: w1+SP, y: 2*(h2+SP), width: w2, height: h2)
                break
            default:
                print("invalid value")
                break
            }
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.image = images[i]
            self.addSubview(iv)
        }
    }
    private func showSeven(images:[UIImage]) {
        let w = self.frame.size.width
        let h = self.frame.size.height
        let w1 = (w - SP) * 0.6
        let h1 = (h - SP) / 2
        let w2 = (w - SP) * 0.4
        let h2 = (h - 2 * SP) / 3
        for i in 0 ..< images.count {
            let iv = UIImageView()
            switch i {
            case 0:
                iv.frame = CGRect(x: 0, y: 0, width: (w1-SP)/2, height: h1)
                break
            case 1:
                iv.frame = CGRect(x: (w1+SP)/2, y: 0, width: (w1-SP)/2, height: h1)
                break
            case 2:
                iv.frame = CGRect(x: 0, y: h1+SP, width: (w1-SP)/2, height: h1)
                break
            case 3:
                iv.frame = CGRect(x: (w1+SP)/2, y: h1+SP, width: (w1-SP)/2, height: h1)
                break
            case 4:
                iv.frame = CGRect(x: w1+SP, y: 0, width: w2, height: h2)
                break
            case 5:
                iv.frame = CGRect(x: w1+SP, y: h2+SP, width: w2, height: h2)
                break
            case 6:
                iv.frame = CGRect(x: w1+SP, y: 2*(h2+SP), width: w2, height: h2)
                break
            default:
                print("invalid value")
                break
            }
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.image = images[i]
            self.addSubview(iv)
        }
    }
}
