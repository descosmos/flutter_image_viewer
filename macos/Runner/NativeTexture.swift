//
//  NativeTexture.swift
//  Runner
//
//  Created by renes on 2025/6/22.
//
import FlutterMacOS
import Foundation
import CoreVideo

public class TextureChannel {
    private static let channelName = "io.flutter.image_viewer/texture"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger
        )
        
        let instance = TextureChannel(registry: registrar.textures)
//        instance.registrar = registrar;
        channel.setMethodCallHandler(instance.handle)
    }
    
//    public var registrar: FlutterPluginRegistrar?
    private var registry: FlutterTextureRegistry

    private var texture: NativeTexture?
    
    init(registry: FlutterTextureRegistry) {
        self.registry = registry
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createTexture":
            if #available(macOS 14.0, *) {
                let arguments = call.arguments as? String
//                let key = registrar?.lookupKey(forAsset: "assets/HDR.HEIC")
                let key = "../Frameworks/App.framework/Resources/flutter_assets/\(arguments!)"
                guard let assetPath = Bundle.main.url(forResource: key, withExtension: nil)  else { return result(nil) }
                texture = NativeTexture(registry: registry, assetPath: assetPath)
                result(texture?.textureId)
            } else {
                result(nil)
            }
        case "dispose":
            if ((texture) != nil) {
                registry.unregisterTexture(texture!.textureId)
                texture = nil
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

var renderer = Renderer()

public class NativeTexture: NSObject, FlutterTexture {
    public var textureId: Int64 = -1
    public var assetPath : URL?
    private weak var registry: FlutterTextureRegistry?
    private var layer: CALayer?
    private var inputImage: CIImage?
    var pixelBuffer: CVPixelBuffer? = nil
    
    init(registry: FlutterTextureRegistry, assetPath: URL?) {
        super.init()
        self.registry = registry
        self.textureId = registry.register(self)
        self.assetPath = assetPath
        var inputImage: CIImage?
        self.layer = CALayer()
        self.layer!.actions = [
            "contents": NSNull()
        ]
        
        self.layer!.contentsGravity = .resizeAspect
        if #available(macOS 14.0, *) {
            let ciOptions: [CIImageOption: Any] = [.applyOrientationProperty: true, .expandToHDR: true]
            inputImage = CIImage(contentsOf: assetPath!, options: ciOptions)
            self.layer?.wantsExtendedDynamicRangeContent = true
            self.inputImage = inputImage
            Task {
                await render(inputImage!)
            }
        } else {
            let ciOptions: [CIImageOption: Any] = [.applyOrientationProperty: true]
            inputImage = CIImage(contentsOf: assetPath!, options: ciOptions)
            self.inputImage = inputImage
            Task {
                await render(inputImage!)
            }
        }
        
    }
    
    func render(_ image: CIImage) async {
        if let pixelBuffer = await renderer.render(image, destinationColorspace: inputImage?.colorSpace) {
            self.pixelBuffer = pixelBuffer
            DispatchQueue.main.async { [self] in
                self.layer!.contents = self.pixelBuffer
                self.registry?.textureFrameAvailable(self.textureId)
            }
        }
    }
    
    deinit {
//        pixelBuffer = nil
    }
    
    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
//        return Unmanaged<CVPixelBuffer>.passRetained(self.pixelBuffer!)
        return nil
    }
    
    @objc public func textureShouldUseDirectLayerBacking() -> Bool {
        return true
    }
    
    @objc public func copyCALayer() -> Unmanaged<CALayer>? {
        return Unmanaged<CALayer>.passRetained(self.layer!)
    }
}

class Renderer {
    
    let queue = DispatchQueue(label: "render")
    let pool: CVPixelBufferPool? = nil

    func render(_ image: CIImage, destinationColorspace: CGColorSpace?) async -> CVPixelBuffer? {
        var context : CIContext
        if #available(macOS 10.14, *) {
            context = CIContext(options: [.name: "Renderer"])
        } else {
            context = CIContext()
        }
        let width = Int(image.extent.size.width)
        let height = Int(image.extent.size.height)
        
        let colorspaceName = String(destinationColorspace?.name ?? "")
        
        if #available(macOS 10.15, *) {
            return await withUnsafeContinuation { continuation in
                queue.async { [context] in
                    let transferFunction: CFString
                    
                    if colorspaceName.contains("HLG") {
                        transferFunction = kCVImageBufferTransferFunction_ITU_R_2100_HLG
                    } else {
                        transferFunction = kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ
                    }
                    
                    // Use appropriate CVPixelBuffer options to ensure HDR support.
                    let attributes: [CFString: Any] = [
                        kCVPixelBufferIOSurfacePropertiesKey: [CFString: Any]() as CFDictionary,
                        kCVPixelBufferMetalCompatibilityKey: true as CFNumber
                    ]
                    var buffer: CVPixelBuffer! = nil
                    // Use the memory-efficient HDR-capable pixel format.
                    let result = CVPixelBufferCreate(nil,
                                                     width,
                                                     height,
                                                     kCVPixelFormatType_420YpCbCr10BiPlanarFullRange,
                                                     attributes as CFDictionary,
                                                     &buffer)
                    
                    guard result == kCVReturnSuccess else {
                        print("Failed to allocate the pixel buffer.")
                        return continuation.resume(returning: nil)
                    }
                    
                    // Set and propogate the colorspace on the pixel buffer.
                    let colorAttachments: [CFString: Any] = [
                        kCVImageBufferYCbCrMatrixKey: kCVImageBufferYCbCrMatrix_ITU_R_2020,
                        kCVImageBufferColorPrimariesKey: kCVImageBufferColorPrimaries_ITU_R_2020,
                        kCVImageBufferTransferFunctionKey: transferFunction
                    ]
                    
                    CVBufferSetAttachments(buffer, colorAttachments as CFDictionary, .shouldPropagate)
                    let destination = CIRenderDestination(pixelBuffer: buffer)
                    do {
                        let task = try context.startTask(toRender: image, to: destination)
                        try task.waitUntilCompleted()
                    } catch {
                        return continuation.resume(returning: nil)
                    }
                    continuation.resume(returning: buffer)
                }
            }
        } else {
            return nil
        }
    }
}
