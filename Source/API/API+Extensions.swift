//
//  API+Extensions.swift
//  IMChatSDK
//
//  Created by Linti on 2020/11/5.
//

//import RealmSwift
//
//extension API {
//    static func current(realm: Realm? = Realm.current) -> API? {
//        guard
//            let auth = AuthManager.isAuthenticated(realm: realm),
//            let host = auth.apiHost?.httpServerURL() ?? auth.apiHost
//        else {
//            return nil
//        }
//
//        let api = API(host: host, version: Version(auth.serverVersion) ?? .zero)
//        api.userId = auth.userId
//        api.authToken = auth.token
//        api.language = AppManager.language
//
//        return api
//    }
//
//    static func server(index: Int) -> API? {
//        let realm = DatabaseManager.databaseInstace(index: index)
//        return current(realm: realm)
//    }
//}

