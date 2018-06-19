var SLDS=SLDS||{};SLDS["__internal/chunked/showcase/ui/components/slider/base/example.jsx.js"]=webpackJsonpSLDS___internal_chunked_showcase([37,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149],{0:function(e,l){e.exports=React},138:function(e,l,a){"use strict";function t(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(l,"__esModule",{value:!0}),l.examples=l.states=l.Slider=void 0;var m=t(a(0)),n=t(a(1)),d=a(11),u="slider-id-01",r=function(e){return m.default.createElement("span",{className:"slds-slider-label"},m.default.createElement("span",{className:"slds-slider-label__label"},"Slider Label"),m.default.createElement("span",{className:"slds-slider-label__range"},e.min||"0"," - ",e.max||"100"))},s=l.Slider=function(e){return m.default.createElement("div",{className:(0,n.default)("slds-slider",e.className)},m.default.createElement("input",{"aria-describedby":e["aria-describedby"],id:e.id||u,className:"slds-slider__range",type:"range",defaultValue:e.value,min:e.min,max:e.max,step:e.step,disabled:e.disabled}),m.default.createElement("span",{className:"slds-slider__value","aria-hidden":"true"},e.value))};l.default=m.default.createElement(d.FormElement,{label:m.default.createElement(r,null),inputId:u},m.default.createElement(s,{value:"50"}));l.states=[{id:"disabled",label:"Disabled",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,null),inputId:u},m.default.createElement(s,{value:"50",disabled:!0}))},{id:"value-0",label:"Value: 0",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,{min:"0",max:"100"}),inputId:u},m.default.createElement(s,{value:"0"}))},{id:"value-25",label:"Value: 25",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,{min:"0",max:"100"}),inputId:u},m.default.createElement(s,{value:"25"}))},{id:"value-50",label:"Value: 50",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,{min:"0",max:"100"}),inputId:u},m.default.createElement(s,{value:"50"}))},{id:"value-75",label:"Value: 75",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,{min:"0",max:"100"}),inputId:u},m.default.createElement(s,{value:"75"}))},{id:"value-100",label:"Value: 100",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,{min:"0",max:"100"}),inputId:u},m.default.createElement(s,{value:"100"}))}],l.examples=[{id:"min-max",label:"Min/Max Range",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,{min:"0",max:"400"}),inputId:u},m.default.createElement(s,{value:"200",min:"0",max:"400"}))},{id:"steps",label:"Min/Max Range with Steps",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,{min:"0",max:"400"}),inputId:u},m.default.createElement(s,{value:"200",min:"0",max:"400",step:"100"}))},{id:"width-x-small",label:"Width: x-small",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,null),inputId:u},m.default.createElement(s,{className:"slds-size_x-small",value:"50"}))},{id:"width-small",label:"Width: small",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,null),inputId:u},m.default.createElement(s,{className:"slds-size_small",value:"50"}))},{id:"width-medium",label:"Width: medium",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,null),inputId:u},m.default.createElement(s,{className:"slds-size_medium",value:"50"}))},{id:"width-large",label:"Width: large",element:m.default.createElement(d.FormElement,{label:m.default.createElement(r,null),inputId:u},m.default.createElement(s,{className:"slds-size_large",value:"50"}))},{id:"error",label:"Error",element:m.default.createElement(d.FormElement,{className:"slds-has-error",label:m.default.createElement(r,null),inputId:u},m.default.createElement(s,{"aria-describedby":"error-message",className:"slds-size_large",value:"50"}),m.default.createElement("div",{id:"error-message",className:"slds-form-element__help"},"There is a problem with this field"))}]}},[138]);