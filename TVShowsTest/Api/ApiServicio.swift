//
//  ApiServicio.swift
//  TVShowsTest
//
//  Created by Abel Lazaro on 08/08/23.
//

import Foundation

class APIServicio {
    
    static let shared = APIServicio()
    
    func getTvShows(completion: @escaping([TVShowsModel]?, Error?) -> ()) {
        let urlString = "https://api.tvmaze.com/search/shows?q=channels"
        
        genericGet(urlString: urlString.folding(options: .diacriticInsensitive, locale: .current).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", params: nil, completion: completion)
    }
    
    private func genericGet<T: Decodable>(urlString: String, params: [String: String]?, completion: @escaping(T?, Error?) -> ()) {
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        if let params = params {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed) else {
                return
            }
            request.httpBody = httpBody
        }
        
        URLSession.shared.dataTask(with: request) { (data, resp, err) in
            if let err = err {
                completion(nil, err)
                print("Error al obtener:", err)
                return
            }
            
            guard let data = data else { return }
            let stringData = String(data: data, encoding: .utf8)
            print("===== AQUIIIIIIIIII: \(stringData ?? "")")
 
            do {
                let objects = try JSONDecoder().decode(T.self, from: data)
              //  print("Data return: ",objects)
     
                completion(objects, nil)
            } catch {
                print("Error al decodificar:", error)
                completion(nil, error)
            }
        }.resume()
    }
    
}
