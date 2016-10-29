
import MetalKit

public class MetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        renderer = Renderer(view: self, device: device!)
        delegate = renderer
    }

}
