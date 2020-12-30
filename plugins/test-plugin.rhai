/// RHAI HOMEPAGE: https://schungx.github.io/rhai/
///
/// HTML in RHAI uses the JSON data model (VIA serde in Rust).
/// For example, the following HTML snippet:
/// ```html
/// <desmos>
///     <expr>y = x^2</expr>
/// </desmos>
/// ```
/// Becomes this in RHAI:
/// ```json
/// [{
///     "tag": "desmos",
///     "styling": {},
///     "attrs": {},
///     "children": [{
///         "tag": "expr",
///         "styling": {},
///         "attrs": {},
///         "children": ["y = x^2"]
///     }]
/// }]
/// ```
/// Note that the `styling` field will probbaly change and is currently unimplemented.

fn new_element_node(tag, attrs, children) {
    #{
        tag: tag,
        attrs: attrs,
        children: children
    }
}
fn new_text_node(txt) {txt}

fn apply(html) {
    new_element_node(
        "div",
        #{macro: "test-plugin"},
        []
    )
}

export let plugins = [
    #{
        type: "tag-macro",
        tag: "test-plugin",
        trans: "apply",
    }
];
