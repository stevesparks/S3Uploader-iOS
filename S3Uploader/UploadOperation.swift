//
//  UploadOperation.swift
//  S3Uploader
//
//  Created by Steve Sparks on 11/20/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AWSS3

class UploadOperation: Operation {
    let accessKey = ""
    let secretKey = ""


    var filepath : String?
    var filename : String?

    let progress = Progress()

    override func main() {
        if let filepath = filepath, let filename = filename {
            upload(filepath: filepath, to: filename)
        } else {
            NSLog("Fail \(filepath)")
        }
    }

    func upload(filepath: String, to filename: String) {
        let cred = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let cfg = AWSServiceConfiguration(region: .usEast1, credentialsProvider: cred)
        AWSServiceManager.default().defaultServiceConfiguration = cfg

        if let req = AWSS3TransferManagerUploadRequest() {
            req.bucket = "wwc-demo"
            req.key = filename
            req.contentType = "image/png"
            req.body = URL(fileURLWithPath: filepath)
            req.uploadProgress = { sent, totalsent, totalexpected in
                self.progress.totalUnitCount = totalexpected
                self.progress.completedUnitCount = totalsent
            }

            if let mgr = AWSS3TransferManager.default(), let task = mgr.upload(req) {
                task.continue({ task in
                    if(task.isCompleted) {

                    } else if let error = task.error {
                        NSLog("Error \(error)")
                    }
                    return nil
                })
            }
        }
    }
}
