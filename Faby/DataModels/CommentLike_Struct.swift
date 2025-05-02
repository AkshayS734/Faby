//
//  CommentLike_Struct.swift
//  Faby
//
//  Created by Vivek kumar on 02/05/25.
//
import Foundation

struct CommentLikeRequest: Codable {
    let user_id: String
    let comment_id: String
    let created_at: String

}
