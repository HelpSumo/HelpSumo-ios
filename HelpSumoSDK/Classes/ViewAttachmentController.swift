//
//  ViewAttachmentController.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 23/12/16.
//
//

import UIKit

class ViewAttachmentController: UIViewController {

    @IBOutlet weak var attachmentImageView: UIImageView!
    
    
    @IBAction func onSavePressed(_ sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(attachmentImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    var attachmentURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let checkedUrl = URL(string: attachmentURL) {
            attachmentImageView.contentMode = .scaleAspectFit
            downloadImage(url: checkedUrl)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                self.attachmentImageView.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
  func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }

}
