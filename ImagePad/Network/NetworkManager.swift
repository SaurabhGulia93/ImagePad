//
//  NetworkManager.swift
//  ImagePad
//
//  Created by Saurabh on 11/11/18.
//  Copyright © 2018 SaurabhGulia. All rights reserved.
//

import Foundation

typealias RequestCompletionHandler = (Data?, Error?) -> Void

class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    private var session: URLSession? = nil
    private var downloadTasks = [URL: URLSessionDownloadTask]()
    private var handlersMap: [String : [RequestCompletionHandler]] = [:]
    
    
    private init(){
        session = URLSession(configuration: .default)
    }
    
    func request(withURL url: URL, completion: @escaping RequestCompletionHandler){
        let dataTask = session?.dataTask(with: url, completionHandler: {[weak self] (data, response, error) in
            if self?.isSuccessResponse(response, error) ?? false{
                completion(data, nil)
            }else{
                completion(nil, error)
            }
        })
        dataTask?.resume()
    }
    
    private func isSuccessResponse(_ response: URLResponse?,_ error: Error?)-> Bool{
        if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse{
            switch httpResponse.statusCode{
            case 200...202:
                return true
            default:
                return false
            }
        }else{
            return false
        }
    }
    
    private func dataFrom(_ tempLocalUrl: URL?) -> Data!{
        guard let tempLocalUrl = tempLocalUrl else{
            return nil
        }
        
        do{
            let data = try Data(contentsOf: tempLocalUrl)
            return data
        }catch{
            return nil
        }
    }
}

// MARK: - Image Download Task
extension NetworkManager {
    
    func download(fromURL url: URL, completion: @escaping RequestCompletionHandler) {
        if downloadTasks.keys.contains(url){
            let downloadTask = downloadTasks[url]
            downloadTask?.priority = URLSessionTask.highPriority
            updateHandlersMap(url: url, completion: completion)
        }else{
            let downloadTask = session?.downloadTask(with: url, completionHandler: {[weak self] (tempLocalUrl, response, error) in
                let completionArr = self?.handlersMap[url.absoluteString] ?? []
                if self?.isSuccessResponse(response, error) ?? false, let data = self?.dataFrom(tempLocalUrl){
                    completionArr.forEach {$0(data, nil) }
                }else{
                    completionArr.forEach {$0(nil, error) }
                }
                
                self?.downloadTasks.removeValue(forKey: url)
            })
            downloadTasks[url] = downloadTask
            updateHandlersMap(url: url, completion: completion)
            downloadTask?.resume()
        }
    }
    
    func updateHandlersMap(url: URL, completion: @escaping RequestCompletionHandler) {
        var completionArr = handlersMap[url.absoluteString] ?? []
        completionArr.append(completion)
        handlersMap[url.absoluteString] = completionArr
    }
    
    func reducePriorityOfTask(withURL url: URL){
        if downloadTasks.keys.contains(url){
            let downloadTask = downloadTasks[url]
            downloadTask?.priority = URLSessionTask.lowPriority
        }
    }
}

