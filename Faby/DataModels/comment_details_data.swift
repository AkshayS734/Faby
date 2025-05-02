//
//  commentdetails data.swift
//  talk
//
//  Created by Batch - 1 on 20/01/25.
//

import Foundation

struct Post: Codable {
    let postId: String
    let postTitle: String
    let postContent: String
    let topicId: String
    let userId: String?
    let createdAt: String? // Default to current time
    let parents: [Parent]? // Make it optional
    let image_url: String?
    
    // Add manual initializer for creating posts directly
    init(postId: String, postTitle: String, postContent: String, topicId: String, userId: String?, createdAt: String?, parents: [Parent]?, image_url: String? = nil) {
        self.postId = postId
        self.postTitle = postTitle
        self.postContent = postContent
        self.topicId = topicId
        self.userId = userId
        self.createdAt = createdAt
        self.parents = parents
        self.image_url = image_url
    }
    
    // Custom decoding to handle parents field correctly
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        postId = try container.decode(String.self, forKey: .postId)
        postTitle = try container.decode(String.self, forKey: .postTitle)
        postContent = try container.decode(String.self, forKey: .postContent)
        topicId = try container.decode(String.self, forKey: .topicId)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        image_url = try container.decodeIfPresent(String.self, forKey: .image_url)
        
        // Handle parents field that can be null or an object or an array
        if let parentContainer = try? container.nestedContainer(keyedBy: ParentCodingKeys.self, forKey: .parents) {
            // It's a single object
            let name = try parentContainer.decode(String.self, forKey: .name)
            parents = [Parent(name: name)]
        } else if let parentsArray = try? container.decodeIfPresent([Parent].self, forKey: .parents) {
            // It's an array
            parents = parentsArray
        } else {
            // It's null or cannot be decoded
            parents = nil
        }
    }
    
    // Coding keys for parent field
    private enum ParentCodingKeys: String, CodingKey {
        case name
    }

    struct Parent: Codable {
        let name: String
    }
}
