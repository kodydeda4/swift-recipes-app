//import ApiClient
//import ComposableArchitecture
//import Foundation
//import SharedModels
//
//extension PersistenceKey where Self == FileStorageKey<Optional<ApiClient.User>> {
//  public static var currentUser: Self {
//    fileStorage(.documentsDirectory.appending(path: "currentUser.json"))
//  }
//}
//
//extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<UserSettings>> {
//  public static var userSettings: Self {
//    PersistenceKeyDefault(
//      .fileStorage(.documentsDirectory.appending(path: "userSettings.json")),
//      UserSettings()
//    )
//  }
//}
//
