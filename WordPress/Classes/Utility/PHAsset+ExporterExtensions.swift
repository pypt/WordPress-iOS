import Foundation
import Photos
import MobileCoreServices
import ImageIO
import AVFoundation

extension PHAsset {
    
    
    typealias SuccessHandler = (resultingSize: CGSize) -> ()
    typealias ErrorHandler = (error: NSError) -> ()

    /**
     Exports an asset to a file URL with the desired targetSize and removing geolocation if requested. 
     The targetSize is the maximum resolution permited, the resultSize will normally be a lower value that maitains the aspect ratio of the asset
     
     - Parameters:
        - url: file url to where the asset should be exported, this must be writable location
        - targetSize:  the maximum pixel resolution that the file can have after exporting. If CGSizeZero is provided the original size of image is returned.
        - stripGeoLocation: if true any geographic location existent on the metadata of the asset will be stripped
        - resultHandler:
     */
    func exportToURL(url: NSURL,
        targetUTI: String,
        targetSize: CGSize,
        stripGeoLocation: Bool,
        successHandler: SuccessHandler,
        errorHandler: ErrorHandler) {
        
        switch self.mediaType {
        case .Image:
            exportImageToURL(url,
                targetUTI: targetUTI,
                targetSize:targetSize,
                stripGeoLocation:stripGeoLocation,
                successHandler:successHandler,
                errorHandler: errorHandler)
        case .Video:
            exportVideoToURL(url,
                targetUTI: targetUTI,
                targetSize:targetSize,
                stripGeoLocation:stripGeoLocation,
                successHandler: successHandler,
                errorHandler: errorHandler)
        default:
            errorHandler(error: errorForCode(.UnsupportedAssetType,
                failureReason: NSLocalizedString("UnsupportedAssetType", comment: "Error reason to display when exporting an unknow asset type from the device library")))
        }
    }
    
    func exportImageToURL(url: NSURL,
        targetUTI: String,
        targetSize:CGSize,
        stripGeoLocation:Bool,
        successHandler: SuccessHandler,
        errorHandler: ErrorHandler) {
        
        let options = PHImageRequestOptions()
        options.version = .Current
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact
        options.synchronous = false
        options.networkAccessAllowed = true
        var requestedSize = targetSize
        if (requestedSize == CGSize.zero) {
            requestedSize = PHImageManagerMaximumSize
        }
        PHImageManager.defaultManager().requestImageForAsset(self, targetSize: requestedSize, contentMode: .AspectFit, options: options) { (image, info) -> Void in
            guard let image = image else {
                if let error = info?[PHImageErrorKey] as? NSError {
                    errorHandler(error: error)
                } else {
                    errorHandler(error: self.errorForCode(.FailedToExport,
                        failureReason: NSLocalizedString("Unknown asset export error", comment: "Error reason to display when the export of a image from device library fails")
                        ))
                }
                return
            }
            self.requestMetadataWithCompletionBlock({ (metadata) -> () in
                do {
                    try image.writeToURL(url, type: targetUTI, compressionQuality: 0.9, metadata: metadata)
                    successHandler(resultingSize: image.size)
                } catch let error as NSError {
                    errorHandler(error: error)
                }
            }, failureBlock:{(error) -> () in
                errorHandler(error: error)
            })
        }
    }
    
    func exportVideoToURL(url: NSURL,
        targetUTI: String,
        targetSize:CGSize,
        stripGeoLocation:Bool,
        successHandler: SuccessHandler,
        errorHandler: ErrorHandler) {
            
            let options = PHVideoRequestOptions()
            options.networkAccessAllowed = true
            PHImageManager.defaultManager().requestExportSessionForVideo(self,
                options: options,
                exportPreset: AVAssetExportPresetPassthrough) { (exportSession, info) -> Void in
                    guard let exportSession = exportSession
                    else {
                        if let error = info?[PHImageErrorKey] as? NSError {
                            errorHandler(error: error)
                        } else {
                            errorHandler(error: self.errorForCode(.FailedToExport,
                                failureReason: NSLocalizedString("Unknown asset export error", comment: "Error reason to display when the export of a image from device library fails")
                                ))
                        }
                        return
                    }
                    exportSession.outputFileType = targetUTI;
                    exportSession.shouldOptimizeForNetworkUse = true
                    exportSession.outputURL = url
                    exportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                        guard exportSession.status == .Completed else {
                            if let error = exportSession.error {
                                errorHandler(error: error)
                            }
                            return;
                        }
                        //dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            successHandler(resultingSize: targetSize)
                        //})
                        
                    })
            }
    }
    
    func exportThumbnailToURL(url: NSURL,
        targetSize:CGSize,
        successHandler: SuccessHandler,
        errorHandler: ErrorHandler) {
            let options = PHImageRequestOptions()
            options.version = .Current
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Fast
            options.synchronous = false
            options.networkAccessAllowed = true
            var requestedSize = targetSize
            if (requestedSize == CGSize.zero) {
                requestedSize = PHImageManagerMaximumSize
            }
            let targetUTI = defaultThumbnailUTI
            PHImageManager.defaultManager().requestImageForAsset(self, targetSize: requestedSize, contentMode: .AspectFit, options: options) { (image, info) -> Void in
                guard let image = image
                else {
                    if let error = info?[PHImageErrorKey] as? NSError {
                        errorHandler(error: error)
                    } else {
                        errorHandler(error: self.errorForCode(.FailedToExport,
                            failureReason: NSLocalizedString("Unknown asset export error", comment: "Error reason to display when the export of a image from device library fails")
                            ))
                    }
                    return
                }
                do {
                    try image.writeToURL(url, type: targetUTI, compressionQuality: 0.9, metadata: nil)
                    successHandler(resultingSize: image.size)
                } catch let error as NSError {
                    errorHandler(error: error)
                }
            }
    }
    
    var defaultThumbnailUTI: String {
        get {
            return kUTTypeJPEG as String
        }
    }
    
    // MARK: - Error Handling
    
    enum ErrorCode : Int {
        case UnsupportedAssetType = 1
        case FailedToExport = 2
        case FailedToExportMetadata = 3
    }
    
    private func errorForCode(errorCode: ErrorCode, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let error = NSError(domain: "PHAsset+ExporterExtensions", code: errorCode.rawValue, userInfo: userInfo)
        
        return error
    }
    
    func requestMetadataWithCompletionBlock(completionBlock:(metadata:[String:AnyObject]) ->(), failureBlock:(error:NSError) -> ()) {
        let editOptions = PHContentEditingInputRequestOptions();
        editOptions.networkAccessAllowed = true;
        self.requestContentEditingInputWithOptions(editOptions) { (contentEditingInput, info) -> Void in
            guard let contentEditingInput = contentEditingInput,
                let fullSizeImageURL = contentEditingInput.fullSizeImageURL,
                let image = CIImage(contentsOfURL:fullSizeImageURL) else {
                    completionBlock(metadata:[String:AnyObject]())
                    if let error = info[PHImageErrorKey] as? NSError {
                        failureBlock(error: error)
                    } else {
                        failureBlock(error: self.errorForCode(.FailedToExportMetadata,
                            failureReason: NSLocalizedString("Unable to export metadata", comment: "Error reason to display when the export of a image from device library fails")
                            ))
                    }
                    return
            }
            completionBlock(metadata:image.properties)
        }
    }
    
    func originalUTI() -> (String?) {
        let resources = PHAssetResource.assetResourcesForAsset(self)
        var types = [];
        if (mediaType == PHAssetMediaType.Image) {
            types = [PHAssetResourceType.Photo.rawValue]
        } else if (mediaType == PHAssetMediaType.Video){
            types = [PHAssetResourceType.Video.rawValue]
        }
        for resource in resources {
            if (types.containsObject(resource.type.rawValue) ) {
                return resource.uniformTypeIdentifier
            }
        }
        return nil
    }
    
    func originalFilename() -> (String?) {
        let resources = PHAssetResource.assetResourcesForAsset(self)
        var types = [];
        if (mediaType == PHAssetMediaType.Image) {
            types = [PHAssetResourceType.Photo.rawValue]
        } else if (mediaType == PHAssetMediaType.Video){
            types = [PHAssetResourceType.Video.rawValue]
        }
        for resource in resources {
            if (types.containsObject(resource.type.rawValue) ) {
                return resource.originalFilename
            }
        }
        return nil
    }
}

extension UIImage {
    // MARK: - Error Handling
    enum ErrorCode : Int {
        case FailedToWrite = 1
    }
    
    private func errorForCode(errorCode: ErrorCode, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let error = NSError(domain: "UIImage+ImageIOExtensions", code: errorCode.rawValue, userInfo: userInfo)
        
        return error
    }
    
    func writeToURL(url: NSURL, type:String, compressionQuality :Float = 0.9,  metadata:[String:AnyObject]? = nil) throws -> ()
    {
        let properties: [String:AnyObject] = [kCGImageDestinationLossyCompressionQuality as String: compressionQuality]
    
        guard let destination = CGImageDestinationCreateWithURL(url, type, 1, nil),
              let imageRef = self.CGImage
        else {
            throw errorForCode(.FailedToWrite,
                failureReason: NSLocalizedString("Unable to write image to file", comment: "Error reason to display when the writing of a image to a file fails")
            )
        }
        CGImageDestinationSetProperties(destination, properties);
        CGImageDestinationAddImage(destination, imageRef, metadata);
        if (!CGImageDestinationFinalize(destination)) {
            throw errorForCode(.FailedToWrite,
                failureReason: NSLocalizedString("Unable to write image to file", comment: "Error reason to display when the writing of a image to a file fails")
            )
        }
    }
}

extension String {

    static func StringFromCFType(cfValue: Unmanaged<CFString>?) -> String? {
        let value = Unmanaged.fromOpaque(cfValue!.toOpaque()).takeUnretainedValue() as CFString
        if CFGetTypeID(value) == CFStringGetTypeID(){
            return value as String
        } else {
            return nil
        }
    }

}