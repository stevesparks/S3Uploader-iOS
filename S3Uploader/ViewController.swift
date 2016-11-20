//
//  ViewController.swift
//  S3Uploader
//
//  Created by Steve Sparks on 11/20/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tap: UITapGestureRecognizer?


    override func viewDidLoad() {
        super.viewDidLoad()

        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        if let tap = tap {
            imageView.addGestureRecognizer(tap)
            imageView.isUserInteractionEnabled = true
        }
    }

    @IBAction func imageTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil);
    }

    func canUpload() -> Bool {
        var answer = true

        if let text = textField.text {
            if text.lengthOfBytes(using: .utf8) < 1 {
                answer = false
            }
        }

        if imageView.image == nil {
            answer = false
        }

        return answer
    }

    @IBAction func buttonTapped(_ sender: Any) {
        if canUpload() {
            let path = "\(NSTemporaryDirectory())/\(UUID().uuidString).png"
            if let img = imageView.image {
                if write(img, to: path) {
                    upload(path)
                }
            }
        } else {
            let c = UIAlertController(title: "Not Ready", message: "Filename? Image? Something is missing.", preferredStyle: .alert)
            c.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(c, animated: true, completion: nil)
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = img
        }
        self.dismiss(animated: true, completion: nil)
    }

    func upload(_ filepath: String) {
        if let text = textField.text {
            let op = UploadOperation()
            op.filepath = filepath
            op.filename = "\(text).png"
            op.completionBlock = { op in
                DispatchQueue.main.async {
                    let c = UIAlertController(title: "Complete", message: "We uploaded", preferredStyle: .alert)
                    c.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(c, animated: true, completion: nil)
                }
            }
            OperationQueue.main.addOperation(op)
        }
    }

    func write(_ image: UIImage, to path: String) -> Bool {
        var result = false
        do {
            let url = URL(fileURLWithPath: path)
            let data = UIImageJPEGRepresentation(image, 0.9)
            try data?.write(to: url)
            result = true
        } catch {

        }

        return result
    }
}

