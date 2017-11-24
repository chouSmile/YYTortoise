//
//  LogUtils.swift
//  SwiftMonkey
//
//  Created by chu on 2017/10/22.
//
//

import Foundation

public class LogUtils {
    
    public init() {
        print("******init*******")
    }
    
    //封装的日志输出功能（T表示不指定日志信息参数类型）
    class func CHULog<T>(_ message:T, file:String = #file, function:String = #function,
                      line:Int = #line) {
        //获取文件名
        let fileName = (file as NSString).lastPathComponent
        //日志内容
        let consoleStr = "\(message)"
        //打印日志内容
        print(consoleStr)
        
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        // 为日期格式器设置格式字符串
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 使用日期格式器格式化当前日期、时间
        let datestr = dformatter.string(from: Date())
        
        //将内容同步写到文件中去（Documents文件夹下）
        let documentPath = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0]
        let logURL = documentPath.appendingPathComponent("test.txt")
        print("*********document path*********\(logURL)")
        appendText(fileURL: logURL, string: "\(consoleStr)")
    }
    
    //在文件末尾追加新内容
    class func appendText(fileURL: URL, string: String) {
        do {
            //如果文件不存在则新建一个
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }
            
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = string + "\n"
            
            //找到末尾位置并添加
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
            
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }
    
    class func getFileContent(fileName: String) -> String{
        let documentPath = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0]
        let file = documentPath.appendingPathComponent(fileName)
        let readHandler = try! FileHandle(forReadingFrom:file)
        let data = readHandler.readDataToEndOfFile()
        let readString = String(data: data, encoding: String.Encoding.utf8)
        //print("文件内容: \(readString!)")
        return readString!
    }
    
    class func convertToDict(_ str: String) -> NSDictionary {
//        let data = str.data(using: String.Encoding.utf8)
//        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
//            return dict
//        }
//        return nil
        
        let jsonData:Data = str.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
}
