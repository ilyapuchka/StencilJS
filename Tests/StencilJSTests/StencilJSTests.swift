//
// StencilJS
// Copyright (c) 2017 Ilya Puchka
// MIT Licence
//

import XCTest
@testable import StencilJS
import Stencil
import JavaScriptCore

class StencilJSTests: XCTestCase {
    
    func template(_ templateString: String, configuringExtension: (JSExtension) -> Void) -> Template {
        let ext = JSExtension()
        configuringExtension(ext)
        return Template(templateString: templateString, environment: Environment(extensions: [ext]))
    }
    
    func testJSFilter() {
        let template = self.template("{{ \"hello\"|jsuppercase }}") { ext in
            ext.registerFilter("jsuppercase", script: "function jsuppercase(value, params) { return value.toUpperCase() }")
        }
        let result = try! template.render([:])
        
        XCTAssertEqual(result, "HELLO")
    }
    
    func testJSFilterWithArguments() {
        let template = self.template("{{ x|jsjoin:\", \" }}") { ext in
            ext.registerFilter("jsjoin", script: "function jsjoin(value, params) { return value.join(params[0]) }")
        }
        let result = try! template.render(["x": ["Hello", "World!"]])
        
        XCTAssertEqual(result, "Hello, World!")
    }
    
    func testJSSimpleTag() {
        let template = self.template("{% jshello %}") { ext in
            ext.registerSimpleTag("jshello", script: "function jshello(context) { return \"Hello, \" + context.valueForKey('name') }")
        }
        let result = try! template.render(["name": "World"])
        
        XCTAssertEqual(result, "Hello, World")
    }
    
    func testJSTag() {
        let template = self.template("{% greet name|capitalize %}Hello, {{ name }}{% endgreet %}") { ext in
            let path = Bundle(for: StencilJSTests.self).path(forResource: "greet-tag", ofType: "js")!
            try! ext.registerTag("greet", script: String(contentsOfFile: path, encoding: .utf8))
        }
        let result = try! template.render(["name": "world"])
        
        XCTAssertEqual(result, "Hello, World")
    }
    
    func testThatItCatchesJavaScriptExceptions() {
        let message = "This is JS exception"
        do {
            let template = self.template("{% jsthrow %}") { ext in
                ext.registerSimpleTag("jsthrow", script: "function jsthrow(context) { throw context.valueForKey('message') }")
            }
            _ = try template.render(["message": message])
            
            XCTFail("No exception caught")
        } catch {
            XCTAssertEqual("\(error)", message)
        }
    }
    
    func testThatItCatchesNativeErrors() {
        do {
            let template = self.template("{% jsthrow %}{% endjsthrow %}") { ext in
                ext.registerTag("jsthrow", script: "function jsthrow(parser, token) { parser.parse(); }")
            }
            _ = try template.render([:])
            
            XCTFail("No exception caught")
        } catch {
            XCTAssertEqual("\(error)", "Unknown template tag \'endjsthrow\'")
        }
    }
    
    func testThatItCanAccessVariable() {
        let template = self.template("{% variable %}") { ext in
            ext.registerSimpleTag("variable", script: "function variable(context) { return new Variable('var').resolve(context) } ")
        }
        let value = "value"
        let result = try! template.render(["var": value])
        
        XCTAssertEqual(result, value)
    }
    
    func testThatItCanAccessVariableNode() {
        let template = self.template("{% variable %}") { ext in
            ext.registerSimpleTag("variable", script: "function variable(context) { return renderNodes([VariableNode('var'), VariableNode(Variable('var'))], context) } ")
        }
        let value = "value"
        let result = try! template.render(["var": value])
        
        XCTAssertEqual(result, "\(value)\(value)")
    }
    
    func testThatItCanPushContext() {
        let template = self.template("{% push %}") { ext in
            ext.registerSimpleTag("push", script: "function push(context) { var level = context.valueForKey('level') + 1; return context.push({'level': level}, function() { return context.valueForKey('level') }) } ")
        }
        let result = try! template.render(["level": 0])
        
        XCTAssertEqual(result, "1")
    }
    
    func testThatItCanGetAndSetContextValue() {
        let template = self.template("{% set %}") { ext in
            ext.registerSimpleTag("set", script: "function set(context) { var level = context.valueForKey('level') + 1; context.setValueForKey(level, 'level'); return context.valueForKey('level') } ")
        }
        let result = try! template.render(["level": 0])
        
        XCTAssertEqual(result, "1")
    }
    
    func testThatItCanAccesTokenProperties() {
        let template = self.template("{% token x %}") { ext in
            ext.registerTag("token", script: "function token(parser, token) { this.render = function(context) { return 'components: ' + token.components().join(', ') + '; contents: ' + token.contents } } ")
        }
        let result = try! template.render([:])
        
        XCTAssertEqual(result, "components: token, x; contents: token x")
    }
}
