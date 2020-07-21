//
//  UIImageView+DownloadingImage.swift
//  StoreSearch
//
//  Created by Thiago on 7/20/20.
//  Copyright © 2020 Curso IOS. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    func loadImage (url:URL) -> URLSessionDownloadTask{
        let downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] urlPath, response, error in
            
            if let error = error {
                print ("Error downoading image: \(error.localizedDescription)")
                return
            }
            guard let urlPath = urlPath,
                  let data = try? Data(contentsOf: urlPath),
                  let image = UIImage(data: data)
                  else {return}
            
            DispatchQueue.main.async {
                guard let weakSelf = self else {return}
                weakSelf.image = image
            }
        })
        downloadTask.resume()
        return downloadTask
    }
    
}
