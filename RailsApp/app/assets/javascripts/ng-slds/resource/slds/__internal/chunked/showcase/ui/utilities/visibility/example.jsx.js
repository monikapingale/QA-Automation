var SLDS=SLDS||{};SLDS["__internal/chunked/showcase/ui/utilities/visibility/example.jsx.js"]=webpackJsonpSLDS___internal_chunked_showcase([5,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149],{0:function(e,s){e.exports=React},171:function(e,s,a){"use strict";Object.defineProperty(s,"__esModule",{value:!0}),s.examples=void 0;var i=function(e){return e&&e.__esModule?e:{default:e}}(a(0));s.examples=[{id:"assistive-text",label:"Assistive Text",element:i.default.createElement("div",{className:"slds-assistive-text"},"I am hidden from sight"),description:"Use the `slds-assistive-text` class to enable a screen reader to read text that is hidden. This class is typically used to accompany icons and other UI elements that show an image instead of text."},{id:"collapsed-expanded",label:"Collapsed / Expanded",element:i.default.createElement("div",{className:"demo-only"},i.default.createElement("div",{className:"slds-is-collapsed"},i.default.createElement("h3",null,"I am collapsed"),i.default.createElement("p",null,"I am a child inside a collapsed element")),i.default.createElement("div",{className:"slds-is-expanded"},i.default.createElement("h3",null,"I am expanded"),i.default.createElement("p",null,"I am a child inside an expanded element"))),description:"The `.slds-is-collapsed` class hides the elements contained inside by controlling the height and overflow properties. Use the `.slds-is-expanded` class to show the elements contained inside in their normal expanded state."},{id:"hidden-visible",label:"Hidden / Visible",element:i.default.createElement("div",{className:"demo-only"},i.default.createElement("div",{className:"slds-hidden"},"I am hidden"),i.default.createElement("div",{className:"slds-visible"},"I am visible")),description:"You can hide an element but reserve the space on the page for when the element is made visible again. To hide the element, use the  `slds-hidden` class. To make it visible again, use the `slds-visible` class."},{id:"hide-show",label:"Hide / Show",element:i.default.createElement("div",{className:"demo-only"},i.default.createElement("div",{className:"slds-hide"},"I am hidden"),i.default.createElement("div",{className:"slds-show"},"I am shown as a block"),i.default.createElement("div",{className:"slds-show_inline-block"},"I am shown as an inline-block")),description:"To hide an element and have it not take up space on the page, use the  `.slds-hide` class. You can toggle the state with JavaScript to show the element at a later&nbsp;time. To make the element visible again, use `.slds-show`. If you need to make the hidden element visible again in an inline-block state, use  `.slds-show_inline-block`."},{id:"transition-hide-show",label:"Transition Hide / Show",element:i.default.createElement("div",{className:"demo-only"},i.default.createElement("div",{className:"slds-transition-hide"},"I have zero opacity"),i.default.createElement("div",{className:"slds-transition-show"},"I have 100% opacity")),description:"To slowly transition an element from hiding and showing, use the  `slds-transition-hide` and `slds-transition-show` classes . They toggle the element's opacity and also reserve its space. Note: To control the timing of the transition, add an additional `transition` property to control the opacity change."},{id:"responsive",label:"Responsive",element:i.default.createElement("div",{className:"demo-only demo-visibility"},i.default.createElement("div",{className:"slds-show_x-small"},"Hides on 319px and down"),i.default.createElement("div",{className:"slds-hide_x-small"},"Hides on 320px and up"),i.default.createElement("div",{className:"slds-show_small"},"Hides on 479px and down"),i.default.createElement("div",{className:"slds-hide_small"},"Hides on 480px and up"),i.default.createElement("div",{className:"slds-show_medium"},"Hides on 767px and down"),i.default.createElement("div",{className:"slds-hide_medium"},"Hides on 768px and up"),i.default.createElement("div",{className:"slds-show_large"},"Hides on 1023px and down"),i.default.createElement("div",{className:"slds-hide_large"},"Hides on 1024px and up"),i.default.createElement("div",{className:"slds-show_x-large"},"Hides on 1279px and down"),i.default.createElement("div",{className:"slds-hide_x-large"},"Hides on 1280px and up")),description:"\nResponsive visibility classes will hide content on specific breakpoints. `slds-show_[breakpoint]` renders `display: none` when the the view port width is smaller than the breakpoint, and does nothing if it is bigger or equal. `slds-hide_[breakpoint]` does the oposite by rendering `display: none` when the the viewport width is bigger or equal than the breakpoint, and does nothing if it is smaller.\n\n|Class Name|Less than 320px|X-Small (>= 320px)|Small (>= 480px)|Medium (>= 768px)|Large (>= 1024px)|X-Large (>= 1280px)|\n|---|---|---|---|---|---|---|\n|`.slds-hide_x-small`|Show|Hide|Hide|Hide|Hide|Hide|\n|`.slds-show_x-small`|Hide|Show|Show|Show|Show|Show|\n|`.slds-hide_small`|Show|Show|Hide|Hide|Hide|Hide|\n|`.slds-show_small`|Hide|Hide|Show|Show|Show|Show|\n|`.slds-hide_medium`|Show|Show|Show|Hide|Hide|Hide|\n|`.slds-show_medium`|Hide|Hide|Hide|Show|Show|Show|\n|`.slds-hide_large`|Show|Show|Show|Show|Hide|Hide|\n|`.slds-show_large`|Hide|Hide|Hide|Hide|Show|Show|\n|`.slds-hide_x-large`|Show|Show|Show|Show|Show|Hide|\n|`.slds-show_x-large`|Hide|Hide|Hide|Hide|Hide|Show|\n    "}]}},[171]);