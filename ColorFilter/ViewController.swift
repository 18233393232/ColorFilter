//
//  ViewController.swift
//  ColorFilter
//
//  Created by 大笨刘 on 2019/5/29.
//  Copyright © 2019 大笨刘. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var imageAfter: UIImageView!
    
    @IBOutlet weak var pickerView: UIView!
    
    var pickerData = UnsafeMutablePointer<UInt32>.allocate(capacity: 4)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    func changeImageBackground(image: UIImage) -> UIImage {
        let width = Int(image.cgImage!.width)
        let height = Int(image.cgImage!.height)
        let pixels = width * height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let data = UnsafeMutablePointer<UInt32>.allocate(capacity: pixels)
        defer {data.deallocate()}
        
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        
        context?.draw(image.cgImage!, in: rect)
        
        let pixelNum = width * height
        var currentPixel = data
        
        for _ in 0..<pixelNum {
//            if currentPixel.pointee & 0xff000000 == 0x00000000 {
//                currentPixel.pointee = 0xffffffff
//            } else if currentPixel.pointee & 0xffffffff == 0xff000000 {
//                currentPixel.pointee = 0xff000000
//            }

            if currentPixel.pointee > self.pickerData.pointee {
                currentPixel.pointee = 0xff00ff00
                // 大端（高位先在低内存地址位置存储），小端（低位先在低内存地址位置存储）
//                let result = self.colourDistance(color1: currentPixel.pointee, color2: self.pickerData.pointee)
//                print("aaaaaaa",result)
                
            }
            currentPixel = currentPixel + 1
        }
        
        let r = UnsafeMutablePointer<CGFloat>.allocate(capacity: pixels)
        let g = UnsafeMutablePointer<CGFloat>.allocate(capacity: pixels)
        let b = UnsafeMutablePointer<CGFloat>.allocate(capacity: pixels)
        let a = UnsafeMutablePointer<CGFloat>.allocate(capacity: pixels)
        defer {r.deallocate()}
        defer {g.deallocate()}
        defer {b.deallocate()}
        defer {a.deallocate()}
        
//        let c = UnsafeMutablePointer<UInt32>.allocate(capacity: <#T##Int#>)
        
        self.pickerView.backgroundColor?.getRed(r, green: g, blue: b, alpha: a)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.pickerView.backgroundColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let newContext = CGContext(data: data, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let outImage = newContext!.makeImage()
        let newImage = UIImage(cgImage: outImage!)
        
        return newImage
    }
    
//    double ColourDistance(RGB e1, RGB e2)
//    {
//    long rmean = ( (long)e1.r + (long)e2.r ) / 2;
//    long r = (long)e1.r - (long)e2.r;
//    long g = (long)e1.g - (long)e2.g;
//    long b = (long)e1.b - (long)e2.b;
//    return sqrt((((512+rmean)*r*r)>>8) + 4*g*g + (((767-rmean)*b*b)>>8));
//    }
 
    // 加权欧式距离
    func colourDistance(color1: UInt32, color2: UInt32) -> Double {
        let red1   = (color1 & 0x000000ff)
        let green1 = (color1 & 0x0000ff00) >> 8
        let blue1  = (color1 & 0x00ff0000) >> 16
        
        let red2   = (color2 & 0x000000ff)
        let green2 = (color2 & 0x0000ff00) >> 8
        let blue2  = (color2 & 0x00ff0000) >> 16
        
        let meanRed = (red1 + red2)/2
        let differRed = red2 - red1
        let differGreen = green1 - green2
        let differBlue = blue2 - blue1
        
        let sub1 = (((512+meanRed)*differRed*differRed)>>8)
        let sub2 = 4*differGreen*differGreen
        let sub3 = (((767-meanRed)*differBlue*differBlue)>>8)
        return sqrt(Double(sub1 + sub2 + sub3))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.randomElement()
        let point = touch?.location(in: self.image)
        
        let color = self.colorAtPixel(point: point!)
        
        self.pickerView.backgroundColor = color
        
//        if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
//
//            UIColor *color = [self colorAtPixel:pointL];
//
//            if (self.currentColorBlock) {
//
//                self.currentColorBlock(color);
//            }
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageAfter.image = self.changeImageBackground(image: image.image!)
    }
    
    //获取图片某一点的颜色
    func colorAtPixel(point: CGPoint) -> UIColor? {
        if !self.image.bounds.contains(point) {
            return nil
        }
    
        let pointX = trunc(point.x)
        let pointY = trunc(point.y)
        let cgImage = self.image.image!.cgImage
        let width = self.image!.bounds.size.width
        let height = self.image!.bounds.size.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * 1
        let bitsPerComponent = 8

        self.pickerData = UnsafeMutablePointer<UInt32>.allocate(capacity: 4)
        
        let context = CGContext(data: self.pickerData, width: 1, height: 1, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context!.setBlendMode(CGBlendMode.copy)

        context!.translateBy(x: -pointX, y: pointY-height)
//
        context!.draw(cgImage!, in: CGRect.init(x: 0, y: 0, width: width, height: height))
    
        
        let red   = self.pickerData.pointee & 0x000000ff
        let green = (self.pickerData.pointee & 0x0000ff00) >> 8
        let blue  = (self.pickerData.pointee & 0x00ff0000) >> 16
        let alpha = (self.pickerData.pointee & 0xff000000) >> 24
        
        print(String(format: "%x", self.pickerData.pointee))
        
        // 疑问 8位指针 和 32位指针 打印
//        var data = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
//
//        data = self.pickerData
//
//        print(String(format: "%x", (data+1).pointee))
//
//        print(String(format: "%x", (data+2).pointee))
//
//        print(String(format: "%x", (data+3).pointee))
        
        print(String(format: "%x %x %x %x", red, green, blue, alpha))
        
        return UIColor.init(red: CGFloat(red)/255.0,
                            green: CGFloat(green)/255.0,
                            blue: CGFloat(blue)/255.0,
                            alpha: CGFloat(alpha)/255.0)
    }

}

