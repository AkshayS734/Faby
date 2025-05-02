//
//  Post_Like_Struct.swift
//  Faby
//
//  Created by Vivek kumar on 28/04/25.
//

import Foundation

struct Likes: Codable { // Codable = Encodable + Decodable
    let Like_id: Int? // It’s auto-generated usually, so optional
    let user_id: String
    let post_id: String
    let created_at: String? // Supabase can auto-fill if you want
}
