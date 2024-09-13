//import ComposableArchitecture
//import Foundation
//import RadarClient
//import SharedModels
//
//extension PersistenceReaderKey where Self == InMemoryKey<RadarClient.Radar?> {
//  /// The connected radar.
//  public static var radar: Self {
//    inMemory("radar")
//  }
//}
//
//extension PersistenceKey where Self == PersistenceKeyDefault<InMemoryKey<RadarClientState>> {
//  public static var radarClientState: Self {
//    PersistenceKeyDefault(
//      .inMemory("radarClientState"),
//      RadarClientState()
//    )
//  }
//}
