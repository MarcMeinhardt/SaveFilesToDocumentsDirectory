//
//  ViewController.swift
//  FilesToDocumentDirectory
//
//  Created by Marc Meinhardt on 30.06.20.
//  Copyright © 2020 Marc Meinhardt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // PROPERTIES :

    enum StorageType {
        case userDefaults
        case fileSystem
    }
    
    @IBOutlet weak var imageToSaveImageView: UIImageView! {
        didSet {
            let imageName = "boosters"
            imageToSaveImageView.image = UIImage(named: imageName)
        }
    }
    @IBOutlet weak var savedImageDisplayImageView: UIImageView!
    
    // VIEW DID LOAD :
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createDirectory()
    }
    
    // FUNCTION :
    
    func createDirectory() {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let imageDataPath = docURL.appendingPathComponent("images")
        let videoDataPath = docURL.appendingPathComponent("videos")
        let gifDataPath = docURL.appendingPathComponent("gifs")

        if !FileManager.default.fileExists(atPath: imageDataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: imageDataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
        if !FileManager.default.fileExists(atPath: videoDataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: videoDataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
        if !FileManager.default.fileExists(atPath: gifDataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: gifDataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print(paths[0])
        return documentsDirectory
    }
    
    
    @IBOutlet weak var saveImageButton: UIButton! {
        didSet {
            saveImageButton.addTarget(self, action: #selector(ViewController.save), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var displaySavedImageButton: UIButton! {
        didSet {
            displaySavedImageButton.addTarget(self, action: #selector(ViewController.display), for: .touchUpInside)
        }
    }
    
    @objc func save() {
        let imageName = "boosters"
        let key = "SavedImage"
        if let image = UIImage(named: imageName) {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                self.store(image: image, forKey: key, withStorageType: StorageType.fileSystem)
            }
        }
    }
    
    @objc func display() {
        let key = "SavedImage"
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            if let savedImage = self.retrieveImage(forKey: key, inStorageType: StorageType.fileSystem) {
                
                DispatchQueue.main.async {
                    self.savedImageDisplayImageView.image = savedImage
                    print("\nSuccessfully displayed image from \(self.filePath(forKey: key)!)")
                }
            }
        }
    }

    // FUNCTION : store image
    
    private func store(image: UIImage, forKey key: String, withStorageType storageType: StorageType) {
        
        if let pngRepresentation = image.pngData() {
            
            switch storageType {
            case StorageType.fileSystem :
                // save to disk
                if let filePath = filePath(forKey: key) {
                    do {
                        try pngRepresentation.write(to: filePath, options: Data.WritingOptions.atomic)
                        print("\nSuccessfully stored image at \(filePath)")
                    } catch let error {
                        print("Failed to save images", error)
                    }
                }
            case StorageType.userDefaults :
                // save to user defaults
                UserDefaults.standard.set(pngRepresentation, forKey: key)
            }
        }
    }
    
    // FUNCTION : retrieve image
    
    private func retrieveImage(forKey key: String, inStorageType storageType: StorageType) -> UIImage? {
        
        switch storageType {
        case StorageType.fileSystem:
            // retrieve image from disk
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData) {
                return image
            }
        case StorageType.userDefaults:
            // retrieve image from user defaults
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        return nil
    }
    
    // HELPER METHOD : file path
    
    private func filePath(forKey key: String) -> URL? {
        
        let fileManager = FileManager.default
        
        //guard let documentURL = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        guard let documentURL = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        let imageFolderURL = documentURL.appendingPathComponent("images", isDirectory: true)
        
        return imageFolderURL.appendingPathComponent(key + ".png")
    }
    
    
}

