//
//  CommentReply_struct.swift
//  Faby
//
//  Created by Batch - 1 on 03/05/25.
//

import Foundation

struct CommentReply: Codable, Identifiable {
    let replyId: Int?
    let commentId: Int      // Parent comment ID this reply is connected to
    let postId: String      // Post ID where this comment belongs
    let userId: String      // User who made the reply
    let replyContent: String // Reply content (changed from content to replyContent)
    let createdAt: String?  // Timestamp
    let parentName: String? // Name of the user who made the reply (from join)
    
    
    enum CodingKeys: String, CodingKey {
        case replyId = "reply_id"
        case commentId = "comment_id"
        case postId = "post_id"
        case userId = "user_id"
        case replyContent = "reply_content" // Updated to match column name
        case createdAt = "created_at"
        case parentName = "parents"
    }
    
    // Implement Identifiable protocol requirement
    var id: String { replyId?.description ?? UUID().uuidString }
    
    // Custom decoding to handle nested parent name
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        replyId = try container.decodeIfPresent(Int.self, forKey: .replyId)
        commentId = try container.decode(Int.self, forKey: .commentId)
        postId = try container.decode(String.self, forKey: .postId)
        userId = try container.decode(String.self, forKey: .userId)
        replyContent = try container.decode(String.self, forKey: .replyContent)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        
        // Handle nested parent name
        if let parentContainer = try? container.nestedContainer(keyedBy: ParentCodingKeys.self, forKey: .parentName),
           let name = try? parentContainer.decode(String.self, forKey: .name) {
            parentName = name
        } else {
            parentName = nil
        }
    }
    
    // Manual initializer for creating replies
    init(replyId: Int? = nil, commentId: Int, postId: String, userId: String, replyContent: String, createdAt: String? = nil, parentName: String? = nil) {
        self.replyId = replyId
        self.commentId = commentId
        self.postId = postId
        self.userId = userId
        self.replyContent = replyContent
        self.createdAt = createdAt
        self.parentName = parentName
    }
    
    private enum ParentCodingKeys: String, CodingKey {
        case name
    }
} 
