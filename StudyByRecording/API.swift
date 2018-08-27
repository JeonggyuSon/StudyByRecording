//
//  API.swift
//  StudyByRecording
//
//  Created by jgson on 2018. 8. 28..
//  Copyright © 2018년 jgson. All rights reserved.
//

import Foundation
import Alamofire

struct Translate: Codable {
    let translatedText: [String]
    
    private enum CodingKeys: String, CodingKey {
        case translatedText = "translated_text"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        translatedText = try container.decode([String].self, forKey: .translatedText)
    }
}

enum APIParam {
    case query(with: String)
    
    /// 사운드 입력 언어.
    var srcLang: String { return "kr" }
    
    /// 번역 언어.
    var targetLang: String { return "en" }
    
    /// Request Parameters.
    var parameters: [String: Any] {
        if case let APIParam.query(query) = self,
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return ["src_lang": srcLang, "target_lang": targetLang, "query": encodedQuery]
        } else {
            return [:]
        }
    }
}

class API {
    static let shared = API()
    
    /// 카카오 번역 API Origin URL.
    private let apiUrl = "https://kapi.kakao.com/v1/translation/translate"
    
    func request(input sound: String) {
        let parameters = APIParam.query(with: sound).parameters
        let headers = ["Authorization": "KakaoAK 622538cc3706c48d373db95c0ff0a105"]
        Alamofire.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            guard let jsonValue = response.result.value else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: jsonValue) else { return }
            guard let translate = try? JSONDecoder().decode(Translate.self, from: data) else { return }
            
            print("\(translate.translatedText)")
        }
    }
}
