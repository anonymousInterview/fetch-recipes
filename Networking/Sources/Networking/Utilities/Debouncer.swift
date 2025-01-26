//
//  Debouncer.swift
//  Networking
//
//

/// A simple implementation of a Debouncer
final class Debouncer {
    private let block: @Sendable () async -> Void
    private let duration: ContinuousClock.Duration
    private var task: Task<Void, Never>?
    
    init(
        duration: ContinuousClock.Duration,
        block: @Sendable @escaping () async -> Void
    ) {
        self.duration = duration
        self.block = block
    }
    
    func emit() {
        self.task?.cancel()
        self.task = Task { [duration, block] in
            do {
                try await Task.sleep(for: duration)
                await block()
            } catch {}
        }
    }
}
