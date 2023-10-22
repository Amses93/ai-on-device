//
//  imageRecognizerModel.swift
//  AI on device uppgifter
//
//  Created by Amel Curic on 2023-10-22.
//

import Foundation
import Vision
import UIKit

class ImageRecognizerModel {
    func doImage(_ image: UIImage) -> String {
        var result: String = ""
        let defaultConfig = MLModelConfiguration()
        
        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? Resnet50(configuration: defaultConfig)
        
        let theimage = image
        let theimageBuffer = buffer(from: theimage)!
        
        do {
            let output = try imageClassifierWrapper!.prediction(image: theimageBuffer)
            
            print(output.classLabel)
            print(output.classLabelProbs[output.classLabel]!)
            
            result = output.classLabel
        } catch {
            print(error)
        }
        
        return result
    }
    
    
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}