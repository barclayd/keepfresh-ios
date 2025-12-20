public extension String {
    func truncated(to length: Int) -> String {
        count > length ? String(prefix(length - 3).trimmingCharacters(in: .whitespaces)) + "…" : self
    }
}
