
import MetalKit

public class Renderer: NSObject, MTKViewDelegate {
    
    public var device: MTLDevice!
    var queue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    var vertexBuffer: MTLBuffer!
    var indicesBuffer: MTLBuffer!
    var vertexCount = 4
    var instanceCount = 100
    
    var instances: [InstanceInfo]!
    var instancesBuffer: MTLBuffer!
    
    struct Vertex {
        var position: float4
    }
    
    struct InstanceInfo {
        var position = matrix_identity_float4x4
    }
    
    override public init() {
        super.init()
        initializeMetal()
        
        // create Vertices - a Quad from 2 triangles, sharing points [1,2]
        let vertexData = [ Vertex(position: [ 0.0, 0.1, 0.0, 1.0]),
                           Vertex(position: [ -0.1, 0.0, 0.0, 1.0]),
                           Vertex(position: [ 0.1, 0.0, 0.0, 1.0]),
                           Vertex(position: [ 0.0, -0.1, 0.0, 1.0])
                        ]
        
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.stride * vertexCount, options:[])
        
        // create indices
        let indices: [UInt16] = [0, 1, 2, 3, 2, 1]
        indicesBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * 6, options:[])
        
        // create a bunch of instances with a random position
        instances = [InstanceInfo](repeatElement(InstanceInfo(), count: instanceCount))
        instancesBuffer = device.makeBuffer(length: instances.count * MemoryLayout<InstanceInfo>.stride, options: [])!
        var pointer = instancesBuffer.contents().bindMemory(to: InstanceInfo.self, capacity: instances.count)
        for _ in instances {
            let x: Float = Float(drand48() - 0.5)
            let y: Float = Float(drand48() - 0.5)
            pointer.pointee.position = float4x4(columns: (
                SIMD4<Float>( 1,  0,  0,  0),
                SIMD4<Float>( 0,  1,  0,  0),
                SIMD4<Float>( 0,  0,  1,  0),
                SIMD4<Float>( x, y,  0,  1)
            ))
            pointer = pointer.advanced(by: 1)
        }
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
            
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].alphaBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
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
        commandEncoder.setVertexBuffer(instancesBuffer, offset: 0, index: 1)
        commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indicesBuffer, indexBufferOffset: 0, instanceCount: instanceCount)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
