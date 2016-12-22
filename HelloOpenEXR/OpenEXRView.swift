
import MetalKit

public class OpenEXRView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        renderer = OpenEXRRenderer(view: self, device: device!)
        delegate = renderer
    }

}
