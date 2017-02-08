## StencilJS

StencilJS is a [Stencil](https://github.com/kylef/Stencil) extension that allows to extend Stencil template engine with custom filters and tags written in JavaScript.

This framework is intended to be used by developers of tools/apps who wants to provide their users an option to write their own tags and filters. It does not provide (at least at this point) any tools to discover such scripts and load them.

### Usage

Link `StencilJS` module to your target, either using SPM, [Carthage](https://fuller.li/posts/using-swift-package-manager-with-carthage/) or CocoaPods.

Then add `JSExtension` to your Stencil `Environment`:

```swift
let ext = JSExtension()
let env = Environment(extensions: [ext])
```

`JSExtension` provides additional methods to register filters and tags using JavaScript code which are similar to the methods to add filters and tags written in Swift:

`func registerFilter(_ name: String, script code: String)`
`func registerSimpleTag(_ name: String, script code: String)`
`func registerTag(_ name: String, script code: String)`

By default each of these methods uses `JSContext` instance from `jsContext` property of `JSExtension`. This way all of your JavaScript code will be executed in the same context. Alternatively you can pass these methods arbitrary `JSContext` instance to make them run the code in isolation.

### Writing filters and tags in JavaScript

Each filter or tag should be defined as a function with the same name that you use to register it for.

Filters should accept two parameters - `value` and `params` and can return transformed value.

```javascript
// template:
{{ name|uppercase }}

// code:
function uppercase(value, params) { 
	return value.toUpperCase() 
}
```

```javascript
// template:
{{ tags|join:', '}}

// code:
function join(value, params) { 
	return value.join(params[0]) 
}
```

Simple tags are tags that can be processed without additional parsing. They accept context as a parameter and should return string.

```javascript
// template:
{% hello %}

// code:
function hello(context) { 
	return \"Hello, \" + context.valueForKey('name') 
}
```

Tags should accept two parameters - `parser` and `token` and should define `render` function that accepts context.

```javascript
function tag(parser, token) {
	// use parser to parse token
	
	this.render = function(contet) {
		// use parsed token to render data from context
	}
}
```
You can check tests or Stencil source code for more detailed examples of tags.

In JavaScript you can use all the same methods of `TokenParser` and `Token`, you can subscript context by key and you can push new level onto the context.

`TokenParser` methods:

- `func parse() -> [NodeType]` - parse the given tokens into nodes
	
- `func parse_until(_ tags: [String]?) -> [NodeType]`  - parse the given tokens into nodes until it finds one of specified tags
	
- `func nextToken() -> Token?` - returns next token without actually parsing it
	
- `func compileFilter(_ token: String) -> Resolvable!` - parses all filters in the token

`Token` methods:

- `func components() -> [String]` - returns the underlying value as an array seperated by spaces

- `var contents: String { get }` - returns the underlying value

`Context` methods:

- `func value(forKey key: String) -> Any?` - returns the value in the context identified by a given key. Usage: `context.valueForKey('name')`

- `func setValue(_ value: Any?, forKey key: String)` - sets the value in the context identified by a given key. Usage: `context.setValueForKey('value', 'key')`

- `func push(_ closure: JSValue) -> Any` - pushed new level onto the context. Usage: `push(function() { ... })`

- `func push(_ dictionary: [String : Any], _ closure: JSValue) -> Any` - pushed new level onto the context with provided values. Usage: `push({'key': 'value'}, function() { ... })`

`Variable` methods:

- `init(_ variable: String)` - creates variable with a name. Usage: `new Variable('var')`

- `func resolve(_ context: Context) -> Any?` - resolves the value of variable or filter expression

`VariableNode` methods:

- `init?(_ variable: JSValue)` - creates variable node with a string or `Resolvable` object. Usage: `new VariableNode('var')` or `new VariableNode(Variable('var'))

- `func render(_ context: Context) throws -> String` - renders the node by resolving corresponding variable

Free functions:

- `func renderNodes([NodeType], Context) -> String` - free function to render array of nodes in a context

## License

Stencil is licensed under the BSD license. See [LICENSE](LICENSE) for more
info.