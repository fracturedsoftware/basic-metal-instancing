
import MetalKit
import PlaygroundSupport

let frame = NSRect(x: 0, y: 0, width: 500, height: 500)
let delegate = Renderer()
let view = MTKView(frame: frame, device: delegate.device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
view.delegate = delegate
PlaygroundPage.current.liveView = view
