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
    
    // New properties for in-place reply functionality
    var isRepliesExpanded: Bool?            // Track if this comment has expanded replies
    var isReply: Bool?                      // Is this a reply to another comment
    var replyToCommentId: Int?              // ID of parent comment if this is a reply
    var isLoadingIndicator: Bool?           // Is this a temporary loading row
    var isEmptyState: Bool?                 // Is this a "no replies" placeholder
    var parentId: String?                   // User ID of the comment author
    var repliesCount: Int?                  // Number of replies to this comment
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case content = "Comment_content"
        case createdAt = "created_at"
        case parentName = "parents"
        case commentId = "Comment_id"
        // New properties aren't in JSON, so they don't need coding keys
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
        
        // Initialize new properties with default values
        isRepliesExpanded = false
        isReply = false
        replyToCommentId = nil
        isLoadingIndicator = false
        isEmptyState = false
        parentId = nil
        repliesCount = nil
    }
    
    // Add a custom initializer for creating special comment objects (loading, empty states, etc.)
    init(commentId: Int?, content: String, parentId: String?, parentName: String?, postId: String, createdAt: String?,
         isLoadingIndicator: Bool? = false, isEmptyState: Bool? = false, isReply: Bool? = false,
         replyToCommentId: Int? = nil, isRepliesExpanded: Bool? = false, repliesCount: Int? = nil) {
        
        self.commentId = commentId
        self.content = content
        self.parentId = parentId
        self.parentName = parentName
        self.postId = postId
        self.userId = parentId ?? ""
        self.createdAt = createdAt
        
        self.isLoadingIndicator = isLoadingIndicator
        self.isEmptyState = isEmptyState
        self.isReply = isReply
        self.replyToCommentId = replyToCommentId
        self.isRepliesExpanded = isRepliesExpanded
        self.repliesCount = repliesCount
    }
    
    private enum ParentCodingKeys: String, CodingKey {
        case name
    }
}
