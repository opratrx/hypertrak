import Foundation

public struct Post: Identifiable {
    public let id: UUID
    public let title: String
    public let content: String
    public let creationDate: Date
    public let postUserID: String

    public init(id: UUID, title: String, content: String, creationDate: Date, postUserID: String) {
        self.id = id
        self.title = title
        self.content = content
        self.creationDate = creationDate
        self.postUserID = postUserID
    }
}

