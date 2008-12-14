// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function search_trigger(element, value) {
    var urls = value.select('a');
    if (urls.length > 0) {
        window.location.href = urls[0].readAttribute('href');
    }
    return false;
}
