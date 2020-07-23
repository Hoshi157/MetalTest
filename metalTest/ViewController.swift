//
//  ViewController.swift
//  metalTest
//
//  Created by 福山帆士 on 2020/07/23.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    // GPUを抽象化
    private let device = MTLCreateSystemDefaultDevice()!
    
    // Bufferの順番を管理
    private var commandQueue: MTLCommandQueue!
    
    // 描画するtexture
    private var texture: MTLTexture!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // metalを描画するview
        let myMtkView = MTKView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), device: device)
        
        view.addSubview(myMtkView)
        
        myMtkView.delegate = self
        
        // 初期化
        commandQueue = device.makeCommandQueue()
        
        // textureをロードするクラス
        let textureLoader = MTKTextureLoader(device: device)
        
        // textureをロード
        texture = try! textureLoader.newTexture(
            name: "view",
            scaleFactor: view.contentScaleFactor,
            bundle: nil)
        
        myMtkView.colorPixelFormat = texture.pixelFormat
        
        myMtkView.enableSetNeedsDisplay = true
        myMtkView.framebufferOnly = false
        
        myMtkView.setNeedsLayout()
        
    }
}

extension ViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        //
        guard let drawable = view.currentDrawable else { return }
        
        // Buffferを作成
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let w = min(texture.width, drawable.texture.width)
        let h = min(texture.height, drawable.texture.height)
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()! // textureをコピーする
        
        blitEncoder.copy(from: texture, // from
                         sourceSlice: 0,
                         sourceLevel: 0,
                         sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                         sourceSize: MTLSizeMake(w, h, texture.depth),
                         to: drawable.texture, // to
                         destinationSlice: 0,
                         destinationLevel: 0,
                         destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        
        blitEncoder.endEncoding()
        
        // drawbleを渡すことでBufferに書き込まれる
        commandBuffer.present(drawable)
        
        // コマンドバッファをエンキュー(GPUに送られる)
        commandBuffer.commit()
        
        commandBuffer.waitUntilCompleted()
    }
    
    
}

