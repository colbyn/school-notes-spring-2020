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
///
/// API EXAMPLE:
/// ```
/// <desmos1>
///     <expr>y = x^2</expr>
/// </desmos1>
/// ```
///

///////////////////////////////////////////////////////////////////////////////
// HTML UTILS
///////////////////////////////////////////////////////////////////////////////

fn is_element(html) {
    type_of(html) == "map" && html.has("tag")
}
fn is_text(html) {
    type_of(html) == "string"
}
fn is_tag(html, tag) {
    is_element(html) && html.tag == tag
}
fn new_element_node(tag, attrs, children) {
    #{
        tag: tag,
        attrs: attrs,
        children: children
    }
}
fn new_text_node(txt) {txt}
fn get_children(html) {
    if is_element(html) && html.has("children") {
        return html.children
    } else {
        return []
    }
}
fn get_attr(html, attr) {
    if is_element(html) && html.attrs.has(attr) {
        return html.attrs.get(attr)
    } else {
        return ()
    }
}
fn get_attr_or(html, attr, def) {
    if is_element(html) && html.attrs.has(attr) {
        return html.attrs.get(attr)
    } else {
        return def
    }
}
fn get_text_contents(html) {
    let contents = "";
    for child in get_children(html) {
        if type_of(child) == "string" {
            contents += child;
        }
    }
    return contents
}

///////////////////////////////////////////////////////////////////////////////
// DESMOS UTILS
///////////////////////////////////////////////////////////////////////////////

fn init_container(uid, width, height) {
    let style = "width:"+width+";height:"+height+";";
    new_element_node(
        "div",
        #{
            id: uid,
            style: style,
        },
        []
    )
}

fn init_script(
    uid,
    math_bounds,
    show_expressions,
    lockViewport,
    xAxisNumbers,
    yAxisNumbers,
    showGrid,
    commands,
) {
    let lines = [
        "window.addEventListener('load', function on_load() {",
        "    var elt = document.getElementById('"+uid+"');",
        "    var options = {",
        "        expressionsCollapsed: true,",
        "        expressions: "+show_expressions+",",
        "        lockViewport: "+lockViewport+",",
        "        settingsMenu: false,",
        "        border: false,",
        "        // xAxisNumbers: "+xAxisNumbers+",",
        "        // yAxisNumbers: "+yAxisNumbers+",",
        "        showGrid: "+showGrid+",",
        "    };",
        "    var calculator = Desmos.GraphingCalculator(elt, options);",
        "    if (",
        "        "+math_bounds+" &&",
        "        "+math_bounds+" !== null &&",
        "        "+math_bounds+" !== undefined",
        "    ) {",
        "        calculator.setMathBounds("+math_bounds+");",
        "    }",
        "    for (cmd of "+commands+") {",
        "        calculator.setExpression(cmd);",
        "    }",
        "});",
    ];
    let code = "";
    for line in lines {
        code += line + "\n";
    }
    new_element_node(
        "script",
        #{},
        [code]
    )
}

///////////////////////////////////////////////////////////////////////////////
// MACRO
///////////////////////////////////////////////////////////////////////////////

fn apply(html) {
    let uid = new_rand_id();
    ///////////////////////////////////////////////////////////////////////////
    // DIV CONTAINER
    ///////////////////////////////////////////////////////////////////////////
    let width = get_attr_or(html, "width", "300px");
    let height = get_attr_or(html, "height", "300px");
    let container = init_container(uid, width, height);
    ///////////////////////////////////////////////////////////////////////////
    // JS SETUP
    ///////////////////////////////////////////////////////////////////////////
    let math_bounds = "null";
    let show_expressions = "false";
    let lockViewport = "true";
    let xAxisNumbers = "false";
    let yAxisNumbers = "false";
    let showGrid = "false";
    ///////////////////////////////////////////////////////////////////////////
    // COMMANDS
    ///////////////////////////////////////////////////////////////////////////
    let commands = "[";
    for child in get_children(html) {
        if is_tag(child, "expr") {
            let latex = get_text_contents(child);
            if latex.len() > 0 {
                let id = new_rand_id();
                commands += "{\"latex\":\""+latex+"\", \"id\":\""+id+"\"},";
            }
        }
    }
    commands += "]";
    ///////////////////////////////////////////////////////////////////////////
    // JS SCRIPT
    ///////////////////////////////////////////////////////////////////////////
    let script = init_script(
        uid,
        math_bounds,
        show_expressions,
        lockViewport,
        xAxisNumbers,
        yAxisNumbers,
        showGrid,
        commands,
    );
    ///////////////////////////////////////////////////////////////////////////
    // DONE
    ///////////////////////////////////////////////////////////////////////////
    new_element_node(
        "div",
        #{macro: "desmos1"},
        [
            container,
            script,
        ]
    )
}

export let plugins = [
    #{
        type: "tag-macro",
        tag: "desmos1",
        trans: "apply",
    }
];
