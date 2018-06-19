var SLDS=SLDS||{};SLDS["__internal/chunked/showcase/ui/components/toast/base/example.jsx.js"]=webpackJsonpSLDS___internal_chunked_showcase([33,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149],{0:function(e,s){e.exports=React},143:function(e,s,t){"use strict";function l(e){return e&&e.__esModule?e:{default:e}}function a(e,s){var t={};for(var l in e)s.indexOf(l)>=0||Object.prototype.hasOwnProperty.call(e,l)&&(t[l]=e[l]);return t}Object.defineProperty(s,"__esModule",{value:!0}),s.examples=s.states=s.Toast=void 0;var n=l(t(0)),i=l(t(3)),d=t(5),r=(l(t(2)),l(t(1))),c=function(e){var s=e.containerClassName,t=e.className,l=e.type,d=e.children;a(e,["containerClassName","className","type","children"]);return n.default.createElement("div",{className:(0,r.default)("slds-notify_container",s)},n.default.createElement("div",{className:(0,r.default)("slds-notify slds-notify_toast",t,l?"slds-theme_"+l:null),role:"alert"},n.default.createElement("span",{className:"slds-assistive-text"},l||"info"),d,n.default.createElement(i.default,{className:"slds-notify__close slds-button_icon-inverse",iconClassName:"slds-button__icon_large",symbol:"close",assistiveText:"Close",title:"Close"})))};s.Toast=c,s.default=n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(c,{type:"info",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"info"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small"},"26 potential duplicate leads were found."," ",n.default.createElement("a",{href:"javascript:void(0);"},"Select Leads to Merge")))));s.states=[{id:"success",label:"Success",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(c,{type:"success",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"success"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small "},"Account ",n.default.createElement("a",{href:"javascript:void(0);"},"ACME - 100")," widgets was created."))))},{id:"warning",label:"Warning",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(c,{type:"warning",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"warning"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small "},"Can’t share file “report-q3.pdf” with the selected User."))))},{id:"error",label:"Error",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(c,{type:"error",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"error"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small "},"Can’t save lead “Sally Wong” because another lead has the same name."))))},{id:"error-with-details",label:"Error With Details",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(c,{type:"error",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"error"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small"},"You've encountered some errors when trying to save edits to Samuel Smith."),n.default.createElement("p",null,"Here's some detail of what happened, being very descriptive and transparent."))))}],s.examples=[{id:"small",label:"Small Column",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem",width:"25rem"}},n.default.createElement("div",{className:"slds-region_narrow slds-is-relative"},n.default.createElement(c,{type:"info",containerClassName:"slds-is-absolute"},n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small"},"26 potential duplicate leads were found.")))))}]}},[143]);