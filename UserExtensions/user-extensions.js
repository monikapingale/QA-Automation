LocatorBuilders.add('parent', function(e) {
    console.log(e)
    if (e.id) {
        return "parent=" + e + '#' + e.id;
    }
    return null;
});
// The "inDocument" is a the document you are searching.
PageBot.prototype.locateElementByParent = function(text, inDocument) {
    console.log(text)
    console.log("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
    // Create the text to search for
    var expectedValue = text + text;

    // Loop through all elements, looking for ones that have
    // a value === our expected value
    var allElements = inDocument.getElementsByTagName("*");
    for (var i = 0; i < allElements.length; i++) {
        var testElement = allElements[i];
        if (testElement.value && testElement.value === expectedValue) {
            return testElement;
        }
    }
    return null;
};

Selenium.prototype.getParent = function(locator, text) {
    th = this.page().findElement(xpath="//span[contains(text(),"+locator+")]/../following-sibling::div").getElementsByTagName('a')
    console.log(th)
    return th
};
Selenium.prototype.doLightening_click_row = function(locator, text) {
    this.page().clickElement(this.page().findElement(xpath="//span[contains(text(),"+locator+")]/../../../../../..").getElementsByTagName('tr')[text].childNodes[2].getElementsByTagName('a')[0])
};
Selenium.prototype.doLightening_assert_form_element = function(locator, text) {
    xpath = "//span[./text()="+locator+"]/../following-sibling::div/descendant::"
    Assert.matches(text, this.page().findElement(xpath=xpath+"a | "+xpath+"input |"+xpath+"span |"+xpath+"select").innerText);
};
Selenium.prototype.doLightening_type = function(locator, text) {
    this.page().findElement(xpath="//span[./text()='"+locator+"']/../following-sibling::input").value = text
};
Selenium.prototype.doLightening_click = function(locator, text) {
    this.page().clickElement(this.page().findElement(xpath="//button[@title='"+locator+"']"))
};
Selenium.prototype.assertValueRepeated = function(locator, text) {
    // All locator-strategies are automatically handled by "findElement"
    var element = this.page().findElement(locator);

    // Create the text to verify
    var expectedValue = text + text;

    // Get the actual element value
    var actualValue = element.value;

    // Make sure the actual value matches the expected
    Assert.matches(expectedValue, actualValue);
};