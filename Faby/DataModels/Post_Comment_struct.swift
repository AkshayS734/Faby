//
//  Post_Comment_struct.swift
//  Faby
//
//  Created by Batch - 1 on 29/04/25.
//
//
import Foundation

struct Comment: Codable, Identifiable {
    let postId: String
    let userId: String
    let content: String
    let createdAt: String?
    let parentName: String?
    let commentId: Int?
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case content = "Comment_content"
        case createdAt = "created_at"
        case parentName = "parents"
        case commentId = "Comment_id"
    }
    
    // Implement Identifiable protocol requirement
    var id: String { postId }
    
    // Custom decoding to handle nested parent name
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        postId = try container.decode(String.self, forKey: .postId)
        userId = try container.decode(String.self, forKey: .userId)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        commentId = try container.decodeIfPresent(Int.self, forKey: .commentId)
        
        // Handle nested parent name
        if let parentContainer = try? container.nestedContainer(keyedBy: ParentCodingKeys.self, forKey: .parentName),
           let name = try? parentContainer.decode(String.self, forKey: .name) {
            parentName = name
        } else {
            parentName = nil
        }
    }
    
    private enum ParentCodingKeys: String, CodingKey {
        case name
    }
}
