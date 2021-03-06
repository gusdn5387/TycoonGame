//
//  Grill.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/06.
//

import Foundation

// MARK: 불판 상태 (안 익은, 익음, 타버림)
enum GrillState {
    case raw, roast, burnt, empty
    
    var title: String {
        switch self {
        case .raw:
            return "안 익음"
        case .roast:
            return "익음"
        case .burnt:
            return "타버림"
        case .empty:
            return "비어있음"
        }
    }
}

// MARK: - Entity
struct Grill {
    let state: GrillState // 불판 상태
    let skewer: Skewer? // 불판에서 구워지고 있는 꼬치 종류
}

// MARK: - Model
class GrillModel {
    private var storage: [Grill] = []
    
    public var count: Int { storage.count }
    
    // MARK: - Model > Create
    public func create(_ data: Grill) {
        self.storage.append(data)
    }
    
    // MARK: - Model > Read
    public func read(at: Int) -> Grill? {
        guard count > at else { return nil }
        return storage[at]
    }
    
    // MARK: - Model > Update
    public func update(at: Int, _ data: Grill) -> Bool {
        guard count > at else { return false }
        self.storage[at] = data
        return true
    }
    
    // MARK: - Model > Delete
    public func delete(at: Int) -> Bool {
        guard count > at else { return false }
        self.storage.remove(at: at)
        return true
    }
}
