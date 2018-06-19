name: Jenkins Run
description: Shows a 'Hello, world!' message on the dashboard
author: Gurock Software
version: 1.0
includes: ^(projects/overview)|(suites/overview)|(suites/view)|(cases/view)
excludes:

    js:
        var browserOptions = "chrome";
var isAdvanced = false;
var specConfiguration = {"windows" : {"browsers" : "Chrome,Firefox,IE" , "jenkinsUrl" : "http://enzqawin.eastus.cloudapp.azure.com:8080/buildByToken/buildWithParameters?token=qaauto" , "railsApiUrl" : "http://enzqawin.eastus.cloudapp.azure.com:3000/application"}, "mac" : { "browsers" : "Chrome,Safari" , "jenkinsUrl" : "http://192.168.193.240:8080/buildByToken/buildWithParameters?token=qaauto" , "railsApiUrl" : "http://192.168.193.240:3000/application" }, "ubuntu" : { "browsers" : "Chrome,Firefox" , "jenkinsUrl" : ""}}
//alert(uiscripts.context.@@users.email);
//alert(uiscripts.context.@@users.name);
//alert(uiscripts.context.@@users.id);
var currentUrl = document.URL.split('group_id=');
var RUN_ID = "";
var arrSuitAndCaseIds = [];
var arrCaseIds = [];
var job = "" ;
var jenkinsURL = "";
var railsApiUrl = "";
var caseId = document.URL.split("cases/view/");
var menuItem = '<a href="#" class="toolbar-button content-header-button button-responsive button-start button"  id="btnJenkinsRun">Run Spec</a>';
$(document).ready(function() {
    /* Adding anchor to header */
    if (caseId.length > 1 && caseId[1].split("&group_by")) {
        caseId = caseId[1].split("&group_by")
        menuItem = '<span class="content-header-icon"><a href="#" class="toolbar-button content-header-button button-responsive button-start button"  id="btnJenkinsRun">Run Spec</a></span>';
        $('.content-header-inner').prepend(menuItem);
    } else if (currentUrl.length > 1) {
        menuItem = '<a href="#" class="toolbar-button content-header-button button-responsive button-start button"  id="btnJenkinsRun">Run Spec</a>';
        $('#contentToolbar').prepend(menuItem);
    } else
        $('.content-header-inner').prepend(menuItem);

    /* Bind the click event
     */
    $('#btnJenkinsRun').click(function() {
        dialogBox = document.getElementById('messageDialog');
        dialogBox.removeChild(dialogBox.lastElementChild);
        $('#browser_options').remove();
        $('.dialog-body').empty();

        changeBrowserList('windows');
        $('.dialog-body').append('<div class="tabs">'+
            '<div class="tab-header"><a href="#" class="tab1 current" onclick="App.Tabs.activate(this)">Operating System</a><a href="#" class="tab2" onclick="App.Tabs.activate(this)">Browser</a></div>'+
            '<div class="tab-body tab-frame">'+
            '<div class="tab tab1" style="display: block;">'+
            '<div class="form-group bottom">'+
            '<label for="fieldOptionsDefault">Select OS</label>'+
            '<select class="form-control form-control-small form-select" name="fieldOptionsDefault" id="fieldOptionsDefault" onchange="changeBrowserList(this.value)">'+
            '<option value="windows" selected="selected">Windows</option>'+
            '<option value="mac">Mac</option>'+
            '</select>'+
            '</div>'+
            '</div><div class="tab tab2" style="display: none;" id="tab2">'+selectBrowser+'</div>');
        $('.dialog-body').append('<a class="toolbar-button toolbar-button-last button-add" id="advanced" onclick="run(true);">Advanced Options</a>');
        var button = '<div class="button-group dialog-buttons"><a class="button button-ok button-left button-positive dialog-action-default" id="btnOk" onclick="run(false);">Ok</a><span><a class="button button-cancel button-left button-negative dialog-action-close"  id="btnCancel">Cancel</a></span></div>';

        $('#messageDialog').append(button);

        App.Dialogs.message('','Spec Configuration Options');
        document.getElementsByClassName('ui-dialog ui-widget ui-widget-content ui-corner-all dialog ui-draggable')[0].style.top = "200px";

        function run(isAdvancedOption) {
            isAdvanced = isAdvancedOption;
            console.log("selected browsers:: "+browserOptions.trim());
            /*Create jenkins url based on OS selection(By default windows)*/
            createJenkinsUrl();

            /*Adding run*/
            for(var suitCasePair in arrSuitAndCaseIds){
                var keys = Object.keys(arrSuitAndCaseIds[suitCasePair]);
                if(uiscripts.context.suite != null)
                    addRun(uiscripts.context.project.id,keys[0],arrSuitAndCaseIds[suitCasePair][keys],uiscripts.context.suite.name+' -'+Date().split('GMT')[0]);
                else
                    addRun(uiscripts.context.project.id,keys[0],arrSuitAndCaseIds[suitCasePair][keys],uiscripts.context.project.name+' -'+Date().split('GMT')[0]);
            }
            jenkinsURL = jenkinsURL+"&job="+job+"&RUN_ID="+RUN_ID+"&BROWSERS="+browserOptions.trim();
            if(job == "StartRailsServer"){
                jenkinsURL = railsApiUrl+"&RUN_ID="+RUN_ID+"&BROWSERS="+browserOptions.trim();
            }
            console.log('url is:: '+jenkinsURL );
            $.ajax({
                url:  jenkinsURL.replace("#","") ,
                type: "GET",
                async: false,
                success: function(result) {
                    if(RUN_ID.split(",").length > 1){
                        window.open(currentUrl[0].split("?")[0] + "?/runs/overview/"+uiscripts.context.project.id, "_self");
                    }else
                        window.open(currentUrl[0].split("?")[0] + "?/runs/view/"+RUN_ID, "_self");

                },
                error: function(result) {
                    for(var runId in RUN_ID.split(","))
                        $.ajax({
                            type: "POST",
                            url: uiscripts.env.page_base+"/api/v2/delete_run/"+RUN_ID.split(",")[runId],
                            contentType: "application/json",
                            async: false,
                            success: function(result) {console.log("Run deleted successfully");}
                        })
                    console.log('Error result' + result.error);
                    $('#browser_options').remove();
                    $('.dialog-body').empty();
                    $('.dialog-body').append("<b>An error occurred while triggering automated tests.</b>");
                    App.Dialogs.error();
                }
            });
        }
});

$(document).on("click", "#groupTree", function() {
    //alert("click bound to document listening for #test-element");
    location.reload();
    //$(document).ready();
    //$('#contentSticky').load();
});

});

function getCaseIds(projectId,suitId,sectionId,caseIds){
    if(caseIds != null && caseIds.length > 0){
        for(var caseId in caseIds)
            $.ajax({
                type: "GET",
                url: uiscripts.env.page_base+"/api/v2/get_case/"+caseIds[caseId],
                contentType: "application/json",
                async: false,
                success: function(result) {
                    if(job == ""){
                        if(result.custom_is_browser_dependent)
                            job="StartRailsServer";
                        else
                            job="TeamQA-BuildRubyScriptManually";
                    }
                    if(result.custom_dependent_cases != null){
                        console.log(result.custom_dependent_cases);
                        arrCaseIds = arrCaseIds.concat(result.custom_dependent_cases.split(","));
                        for(var dpendentCaseId in arrCaseIds){
                            console.log(arrCaseIds[dpendentCaseId]);
                            $.ajax({
                                type: "GET",
                                url: uiscripts.env.page_base+"/api/v2/get_case/"+arrCaseIds[dpendentCaseId],
                                contentType: "application/json",
                                async: false,
                                success: function(result) {
                                    if(result.custom_dependent_cases != null)
                                        arrCaseIds = arrCaseIds.concat(result.custom_dependent_cases.split(","));
                                }
                            });
                        }
                    }
                    arrCaseIds.push(result.id);
                }})
        if(arrCaseIds.length > 0){
            var mapSuitCase = {};
            //if(caseIds.length > 1){
            //mapSuitCase[suitId] = caseIds;
            //}
            //else
            mapSuitCase[suitId] = arrCaseIds;
            arrSuitAndCaseIds.push(mapSuitCase);

        }

        console.log('map to add run'+mapSuitCase[suitId]);
    }else
    if(projectId != null && suitId == null && sectionId == null){
        $.ajax({
            type: "GET",
            url: uiscripts.env.page_base+"/api/v2/get_suites/"+projectId,
            contentType: "application/json",
            async: false,
            success: function(result) {
                var suits = result;
                if(result)
                    for(var suit in suits){
                        $.ajax({
                            type: "GET",
                            url: uiscripts.env.page_base+"/api/v2/get_sections/"+projectId+'&suite_id='+suits[suit].id,
                            contentType: "application/json",
                            async: false,
                            success: function(result) {
                                var sections = result;
                                if(result)
                                    for(var section in sections){

                                        $.ajax({
                                            type: "GET",
                                            url: 	uiscripts.env.page_base+"/api/v2/get_cases/"+projectId+'&suite_id='+suits[suit].id+'&section_id='+sections[section].id,
                                            contentType: "application/json",
                                            async: false,
                                            success: function(result) {
                                                if(result)
                                                    for(var caseInfo in result)
                                                        if(result[caseInfo].custom_spec_location != null)
                                                            if(job == ""){
                                                                if(result[caseInfo].custom_is_browser_dependent)
                                                                    job="StartRailsServer";
                                                                else
                                                                    job="TeamQA-BuildRubyScriptManually";
                                                            }
                                                arrCaseIds.push(result[caseInfo].id);


                                            },
                                            error: function(error)
                                            {
                                                console.log(error);
                                            }
                                        });
                                    }
                            },
                            error: function(error)
                            {
                                console.log(error);
                            }
                        });
                        if(arrCaseIds.length > 0){
                            var mapSuitCase = {};
                            mapSuitCase[suits[suit].id] = arrCaseIds;
                            arrSuitAndCaseIds.push(mapSuitCase);
                        }
                        arrCaseIds = []
                    }
            },
            error: function(error)
            {
                console.log(error);
            }
        });
    }else if( projectId != null && suitId != null && sectionId == null ){
        $.ajax({
            type: "GET",
            url: uiscripts.env.page_base+"/api/v2/get_sections/"+projectId+'&suite_id='+suitId,
            contentType: "application/json",
            async: false,
            success: function(result) {
                var sections = result;
                if(result)
                    for(var section in sections){

                        console.log('section :: '+sections[section].id);
                        $.ajax({
                            type: "GET",
                            url: 	uiscripts.env.page_base+"/api/v2/get_cases/"+projectId+'&suite_id='+suitId+'&section_id='+sections[section].id,
                            contentType: "application/json",
                            async: false,
                            success: function(result) {

                                if(result)
                                    for(var caseInfo in result){

                                        if(result[caseInfo].custom_spec_location != null){
                                            //console.log('spec locations'+result[caseInfo].custom_spec_location);
                                            if(job == ""){
                                                if(result[caseInfo].custom_is_browser_dependent)
                                                    job="StartRailsServer";
                                                else
                                                    job="TeamQA-BuildRubyScriptManually";
                                            }
                                            //console.log('case:: ' +result[caseInfo].id);
                                            arrCaseIds.push(result[caseInfo].id);
                                        }
                                    }
                            },
                            error: function(error)
                            {
                                console.log(error);
                            }
                        });
                    }
                if(arrCaseIds.length > 0){
                    //console.log('adding suit to run :: '+suitId);
                    var mapSuitCase = {};
                    mapSuitCase[suitId] = arrCaseIds;
                    arrSuitAndCaseIds.push(mapSuitCase);
                }
                arrCaseIds = [];
            },
            error: function(error)
            {
                console.log(error);
            }
        });
    }else if( projectId != null && suitId != null && sectionId != null ){
        $.ajax({
            type: "GET",
            url: 	uiscripts.env.page_base+"/api/v2/get_cases/"+projectId+'&suite_id='+suitId+'&section_id='+sectionId,
            contentType: "application/json",
            async: false,
            success: function(result) {

                if(result)
                    for(var caseInfo in result){

                        if(result[caseInfo].custom_spec_location != null){

                            if(job == ""){
                                if(result[caseInfo].custom_is_browser_dependent)
                                    job = "StartRailsServer";
                                else
                                    job = "TeamQA-BuildRubyScriptManually";

                            }
                            arrCaseIds.push(result[caseInfo].id);
                        }
                    }
                if(arrCaseIds.length > 0){
                    var mapSuitCase = {};
                    mapSuitCase[suitId] = arrCaseIds;
                    arrSuitAndCaseIds.push(mapSuitCase);
                }
            },
            error: function(error)
            {
                console.log(error);
            }
        });
    }
    console.log("Suit Case Id array :: "+arrSuitAndCaseIds)

}

function addRun(projectId,suitId,arrCaseIds,name){

    var data  = JSON.stringify({"suite_id":suitId,"name":name ,"include_all": false,"case_ids": arrCaseIds})
    $.ajax({
        type: "POST",
        url: uiscripts.env.page_base+"/api/v2/add_run/"+projectId,
        dataType: 'json',
        contentType: "application/json",
        data: data,
        async: false,
        success: function(result) {
            console.log('Success result' +result.id);
            if(RUN_ID != ""){
                RUN_ID = RUN_ID+','+result.id;
            }else
                RUN_ID += result.id
            console.log('run id is'+RUN_ID)
        },
        error: function(error)
        {
            console.log(error);
        }
    });
}

function createJenkinsUrl(){
    if (caseId.length > 1 && caseId[1].split("&group_by")) {
        console.log(caseId[0]);
        getCaseIds(null,uiscripts.context.suite.id,null,[caseId[0]]);
        console.log('case array'+arrCaseIds);
        jenkinsURL = jenkinsURL+"&PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1].split('&')[0]+"&CASE_ID="+arrCaseIds.join(',');
        if(isAdvanced)
            railsApiUrl = 	railsApiUrl+"/advancedOptions?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1]+"&CASE_ID="+arrCaseIds.join(',');
        else
            railsApiUrl = railsApiUrl+"?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1]+"&CASE_ID="+arrCaseIds.join(',');

    } else if (currentUrl.length > 1) {
        if(App.Tables.getSelected().length > 0){
            getCaseIds(uiscripts.context.project.id,uiscripts.context.suite.id,currentUrl[1],App.Tables.getSelected().filter(Boolean));
            console.log('case array'+arrCaseIds);
            jenkinsURL = jenkinsURL+"&PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1].split('&')[0]+"&CASE_ID="+arrCaseIds.join(',');
            if(isAdvanced)
                railsApiUrl = railsApiUrl+"/advancedOptions?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1].split('&')[0]+"&CASE_ID="+arrCaseIds.join(',');
            else
                railsApiUrl = railsApiUrl+"?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1].split('&')[0]+"&CASE_ID="+arrCaseIds.join(',');
        }
        else{
            getCaseIds(uiscripts.context.project.id,uiscripts.context.suite.id,currentUrl[1])

            jenkinsURL = jenkinsURL+"&PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1].split('&')[0];
            if(isAdvanced)
                railsApiUrl = railsApiUrl+"/advancedOptions?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1].split('&')[0];
            else
                railsApiUrl = railsApiUrl+"?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id+"&SECTION_ID="+currentUrl[1].split('&')[0];
        }

    } else if (uiscripts.context.project != null && uiscripts.context.suite != null) {
        getCaseIds(uiscripts.context.project.id,uiscripts.context.suite.id,null)

        jenkinsURL = jenkinsURL+"&PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id;
        if(isAdvanced)
            railsApiUrl = railsApiUrl+"/advancedOptions?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id;
        else
            railsApiUrl = railsApiUrl+"?PROJECT_ID="+uiscripts.context.project.id+"&SUIT_ID="+uiscripts.context.suite.id;

    } else {
        getCaseIds(uiscripts.context.project.id,null,null)
        jenkinsURL = jenkinsURL+"&PROJECT_ID="+uiscripts.context.project.id;
        if(isAdvanced)
            railsApiUrl = railsApiUrl+"/advancedOptions?PROJECT_ID="+uiscripts.context.project.id;
        else
            railsApiUrl = railsApiUrl+"?PROJECT_ID="+uiscripts.context.project.id;
    }
    alert(railsApiUrl );

}
function changeBrowserList(selectedOS){
    jenkinsURL = specConfiguration[selectedOS]['jenkinsUrl'];
    railsApiUrl = specConfiguration[selectedOS]['railsApiUrl'];
    row = ""
    browserOptions= specConfiguration[selectedOS]['browsers'].split(",")[0].toLowerCase();
    for(browser in specConfiguration[selectedOS]['browsers'].split(",")){
        if(browser == 0){row +=  '<tr class="row odd"><td class="checkbox"><input type="checkbox" checked value="'+specConfiguration[selectedOS]['browsers'].split(",")[browser].toLowerCase()+'" class="selectionCheckbox" name="'+specConfiguration[selectedOS]['browsers'].split(",")[browser].toLowerCase()+'" onclick="addBrowserOptions(this);"></td><td style="margin-left: 2em"><span class="title">'+specConfiguration[selectedOS]['browsers'].split(",")[browser]+'</span></td></tr>';}
        else{
            row += '<tr class="row odd"><td class="checkbox"><input type="checkbox" value="'+specConfiguration[selectedOS]['browsers'].split(",")	[browser].toLowerCase()+'" class="selectionCheckbox" name="'+specConfiguration[selectedOS]['browsers'].split(",")[browser].toLowerCase()+'" 	onclick="addBrowserOptions(this);"></td><td style="margin-left: 2em"><span class="title">'+specConfiguration[selectedOS]['browsers'].split(",")	[browser]+'</span></td></tr>'}}
    selectBrowser = '<span id="browser_options"><p class="io-label" style="margin-left: 2em">Select Browser</p><table class="grid selectable" style="text-align:left;">'+row+'</table></span>'
    $(".dialog-body #tab2").empty();
    $(".dialog-body #tab2").append(selectBrowser);
}

function addBrowserOptions(element){
    if(element.checked == true){
        browserOptions = browserOptions+" "+element.value;
        console.log(browserOptions.trim());
    }else{
        browserOptions = browserOptions.replace(""+element.value,"");
        console.log(browserOptions.trim());
    }
}