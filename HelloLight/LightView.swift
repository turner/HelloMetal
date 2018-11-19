
import MetalKit

public class LightView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        
        if let device = device {
            renderer = LightRenderer(view: self, device: device)
            delegate = renderer
        } else {
            fatalError("Error: Failure to create device")
        }

     }

}
