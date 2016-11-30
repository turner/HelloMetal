
import MetalKit

public class LightView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        renderer = LightRenderer(view: self, device: device!)
        delegate = renderer
    }

}
