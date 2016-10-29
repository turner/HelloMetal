
import MetalKit

public class RenderPassMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        renderer = RenderPassRenderer(view: self, device: device!)
        delegate = renderer
    }

}

