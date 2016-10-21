import GLKit

struct Vertex {
    var xyzw: GLKVector4
    var rgba: GLKVector4
    var st: GLKVector2
    
    init(xyzw: GLKVector4, rgba: GLKVector4, st: GLKVector2) {
        self.xyzw = xyzw
        self.rgba = rgba
        self.st = st
    }
}

extension CGRect {
    
    func description (blurb: String?=nil) {
        
        let str = blurb ?? "---"
        
        print("\(str) \(origin.x) \(origin.y) \(size.width) \(size.height)")
    }
}

extension GLKVector3 {
    
    func description (blurb: String?=nil) {
        
        let str = blurb ?? "---"
        
        print("\(str) \(self.x) \(self.y) \(self.z)")
    }
}

extension GLKMatrix4 {
    
    func description (blurb: String?=nil) {
        
        let str = blurb ?? "---"
        
        print("\(str)\n")
        print("\(self.m00) \(self.m01) \(self.m02) \(self.m03)\n")
        print("\(self.m10) \(self.m11) \(self.m12) \(self.m13)\n")
        print("\(self.m20) \(self.m21) \(self.m22) \(self.m23)\n")
        print("\(self.m30) \(self.m31) \(self.m32) \(self.m33)\n")
    }
}

func * (_ left: GLKMatrix4, _ right: GLKVector3) -> GLKVector3 {
    return GLKMatrix4MultiplyVector3(left, right)
}

func * (_ left: GLKMatrix4, _ right: GLKVector4) -> GLKVector4 {
    return GLKMatrix4MultiplyVector4(left, right)
}

func * (_ left: GLKMatrix4, _ right: GLKMatrix4) -> GLKMatrix4 {
    return GLKMatrix4Multiply(left, right)
}

func smoothStep(value:Float, lower:Float, upper:Float) -> Float {
    
    //	// This implementation from:
    //	// Texture & Modeling A Procedural Approach: http://bit.ly/cguJIQ
    //    // By David S. Ebert et al
    //    // pp. 26-27
    //
    //    if (value < lower) return 0.0;
    //
    //    if (value > upper) return 1.0;
    //
    //	// Normalize to 0:1
    //    value = (value - lower)/(upper - lower);
    
    let result = saturate(value: (value - lower)/(upper - lower))
    
    return (result * result * (3.0 - 2.0 * result));
    
}

func saturate(value:Float) -> Float {
    
    return clamp(value: value, lower:0, upper:1);
}

func clamp(value:Float, lower:Float, upper:Float) -> Float {
    
    if (value < lower) {
        return lower
    } else if (value > upper) {
        return upper
    } else {
        return value
    }
    
    
}
