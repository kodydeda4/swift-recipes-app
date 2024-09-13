import Combine

/// `AsyncStream`with multiple subscribers.
/// https://stackoverflow.com/questions/75776172/passthroughsubjects-asyncpublisher-values-property-not-producing-all-values
public final class Channel<Output> {
  private let subject = PassthroughSubject<Output, Never>()
  private var cancellable: AnyCancellable?

  public init(cancellable: AnyCancellable? = nil) {
    self.cancellable = cancellable
  }

  public func send(_ value: Output) {
    subject.send(value)
  }

  public func values() -> AsyncStream<Output> {
    AsyncStream { continuation in
      cancellable = subject.sink { value in
        continuation.yield(value)
      }

      continuation.onTermination = { [weak self] _ in
        self?.cancellable = nil
      }
    }
  }
}

extension Channel: Equatable where Output: Equatable {
  public static func == (lhs: Channel<Output>, rhs: Channel<Output>) -> Bool {
    lhs === rhs
  }
}
