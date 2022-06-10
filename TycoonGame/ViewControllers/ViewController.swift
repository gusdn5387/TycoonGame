//
//  ViewController.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/05.
//

import UIKit

class ViewController: UIViewController {
    let skewerModel = SkewerModel()
    let grillModel = GrillModel()
    let guestModel = GuestModel()
    
    var life = 3 // 라이프
    var sales = 0 // 매출액
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSkewer()
        
        createGrillThread(at: 0) // 0번째 불판
        createGrillThread(at: 1)
        createGrillThread(at: 2)
        
        createGuestThread()
    }
    
    // MARK: 불판에 올라간 꼬치 상태 업데이트
    private func grillStatusUpdate(at: Int, _ data: Grill) -> Bool {
        var isRunning: Bool
        
        switch data.status {
        case .raw:
            print("😀 \(data.skewer.type) 꼬치가 맛있게 익었어요 !!!")
            self.grillModel.update(at: at, Grill(status: .roast, skewer: data.skewer))
            isRunning = true
            break
        case .roast:
            print("😥 \(data.skewer.type) 이런 꼬치가 다 타버렸어요 !!!")
            self.grillModel.update(at: at, Grill(status: .burnt, skewer: data.skewer))
            isRunning = false
            break
        case .burnt:
            isRunning = false
        }
        
        return isRunning
    }
    
    // MARK: 꼬치 생성 (떡꼬치, 닭꼬치, 양꼬치)
    private func createSkewer() {
        skewerModel.create(Skewer(type: .ricecake, time: 5, price: 500, count: 0))
        skewerModel.create(Skewer(type: .chicken, time: 7, price: 1500, count: 0))
        skewerModel.create(Skewer(type: .lamb, time: 10, price: 3000, count: 0))
    }
    
    // MARK: 불판 상태 변경에 대한 스레드 생성
    private func createGrillThread(at: Int) {
        guard let skewer = skewerModel.read(at: at) else { return }
        
        grillModel.create(Grill(status: .raw, skewer: skewer))
        
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: TimeInterval(skewer.time), repeats: true) { _ in
                guard let grill = self.grillModel.read(at: at) else { return }
                
                isRunning = self.grillStatusUpdate(at: at, grill)
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.5))
            }
        }
    }
    
    // MARK: 손님 생성에 대한 스레드 생성
    private func createGuestThread() {
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                if self.guestModel.count >= 3 { isRunning = false }
                else { self.createGuest() }
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(1))
            }
        }
    }
    
    // MARK: 손님 생성
    private func createGuest() {
        let type = GuestType.allCases.randomElement()! // 손님 종류 랜덤값
        let order = setOrder()
        let watingTime = setGuestWatingTime(type, order: order) // 대기 시간
        
        print("type: \(type), order: \(order), watingTime: \(watingTime)")
        guestModel.create(Guest(type: type, time: watingTime, order: order))
    }
    
    // MARK: 손님 주문 내역 설정
    private func setOrder() -> [Int]{
        var order: [Int] = []
        
        for _ in 0 ..< skewerModel.count {
            let count = Int.random(in: 0 ... 3)
            order.append(count)
        }
        
        // 모든 꼬치의 주문 개수가 0일 때
        if (order == [0, 0, 0]) {
            order[Int.random(in: 0 ..< skewerModel.count)] = 1
        }
        
        return order
    }
    
    // MARK: 손님 대기 시간 설정
    private func setGuestWatingTime(_ type: GuestType, order: [Int]) -> Float {
        var multiple: Float = 0 // 손님 종류에 따른 대기 시간 설정을 위함
        var time: Float = 0
        
        switch type {
        case .relax:
            multiple = 2.0
            break
        case .normal:
            multiple = 1.5
            break
        case .impatient:
            multiple = 1.3
            break
        }
        
        order.enumerated().forEach { i, count in
            guard let skewer = self.skewerModel.read(at: i) else { return }
            
            time += Float(count * skewer.time)
        }
        
        return time * multiple
    }
}

