
import MetalKit


public class Renderer: NSObject, MTKViewDelegate {
    
    public var device: MTLDevice!
    var queue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    var vertexBuffer: MTLBuffer!
    var indicesBuffer: MTLBuffer!
    var instanceCount = 1
    
    struct Vertex {
        var position: float4
    }
    
    override public init() {
        super.init()
        initializeMetal()
        
        let vertexData = [ Vertex(position: [ 0.0, 0.1, 0.0, 1.0]),
                           Vertex(position: [ -0.1, 0.0, 0.0, 1.0]),
                           Vertex(position: [ 0.1, 0.0, 0.0, 1.0])]
        
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.stride * 3, options:[])
        
        let indices: [UInt16] = [ 0, 1, 2 ]
        
        indicesBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * 3, options:[])
    }
  
    
    func initializeMetal() {
        device = MTLCreateSystemDefaultDevice()
        queue = device.makeCommandQueue()
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = 16

        let library: MTLLibrary
        do {
            let path = Bundle.main.path(forResource: "Shaders", ofType: "metal")
            let source = try String(contentsOfFile: path!, encoding: .utf8)
            library = try device.makeLibrary(source: source, options: nil)
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.vertexFunction = library.makeFunction(name: "vertex_shader")
            descriptor.fragmentFunction = library.makeFunction(name: "fragment_shader")
            
            descriptor.vertexDescriptor = vertexDescriptor
            
//            descriptor.colorAttachments[0].isBlendingEnabled = true
//            descriptor.colorAttachments[0].rgbBlendOperation = .add
//            descriptor.colorAttachments[0].alphaBlendOperation = .add
//            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error as NSError {
            fatalError("library error: " + error.description)
        }
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {  }
    
    public func draw(in view: MTKView) {
        guard let commandBuffer = queue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
              let drawable = view.currentDrawable else { fatalError() }

        commandEncoder.setRenderPipelineState(pipelineState)

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: 3, indexType: .uint16, indexBuffer: indicesBuffer, indexBufferOffset: 0, instanceCount: instanceCount)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
