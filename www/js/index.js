/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

 // global variables
var tags = {}
var curTag = "";
var resourceLinks = [
    { "title" : "Stackoverflow", 
    "link" : "http://stackoverflow.com/tags/<tag>/info"
    },
    { "title" : "Wikipedia", 
    "link" : "http://en.m.wikipedia.org/wiki/<tag>"
    },
    { "title" : "Quora", 
    "link" : "http://www.quora.com/search?q=<tag>"
    }
];


 $(document).on('pageinit', '#terms', function(){

    updateList(tags, '#termslist','#tag_detail');        

    $('#termslist').on('click', 'a', function(e) {
        // store selected tag into global variable for use on detail page
        localStorage.setItem('curTag', this.id);
        curTag = this.id;
    });

});


var ajax = { 
    parseJSON:function(result){ 
        tags = result.Terms;
        localStorage.setItem('tags', JSON.stringify(tags));
    }
}  


var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();

        tags = localStorage.getItem('tags');
        if (!tags) {
            var url = 'http://brisksoft.us/glossary/getterms.php?tag=';       
            $.ajax({
                url: url ,
                dataType: "json",
                async: true,
                success: function (result) {
                    ajax.parseJSON(result);
                },
                error: function (request,error) {
                    alert('Network error has occurred please try again!');
                }
            }); 
        } else {
            tags = JSON.parse(tags);
        }

    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');

    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
//        var listeningElement = parentElement.querySelector('.listening');
//        var receivedElement = parentElement.querySelector('.received');

 //       listeningElement.setAttribute('style', 'display:none;');
 //       receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

function updateList(data, listId, target) {
    // called to populate list on initial load and when sorting    
    $(listId).empty();
    $.each(data, function(i, tag) {
        $(listId).append('<li><a href="' +target+ '" id="' + tag.title + '"><h3>' + tag.title + '</h3></a></li>');
    });
    $(listId).listview().listview('refresh');
}

function sortList(listId, target) {
    updateList(tags.reverse(), listId, target)
}

function getTag(tag) {

    for (var i=0; i < tags.length; i++) {
        if (tags[i].title == tag) {
            return tags[i];
            break;
        }
    }
}

function filterTags(filterVal) {
    var tmpArray = alltags;
    if (filterVal == 'cat') {
        tmpArray = alltags.filter(function (el) {
          return el.isCat == 1;
        });
        // hide search box
        $("#tags .ui-filterable").toggle();
        $('#tagslist').listview({autodividers: false}).listview('refresh');
    } else {        
        // unhide search box
        $("#tags .ui-filterable").toggle();
        $('#tagslist').listview({autodividers: true}).listview('refresh');
    }
    updateList(tmpArray, '#tagslist', '#relatedtags');
}

function loadJobs() {

    if (!$( "#kw" ).val()) { alert("please enter a skill or keyword."); }
    else {
        var kw = $( "#kw" ).val();

        if (ga) { 
          ga('send', 'event', 'jobs', 'search', kw);
        }

        var loc = ($( "#loc" ).val()) ? $( "#loc" ).val() : "";
        var url = 'http://brisksoft.herokuapp.com/getsalaries?location=' +loc + '&kw=' + kw;  
        $.getJSON( url, function( data ) {
            $("#jobs_list").empty();
            $.each(data, function(i, job) {
                if (i == 0) {
                    $("#jobs_list").append('<li><h3>Avg \'' + job.title + '\' salaries</h3><span class="ui-li-aside"><strong>' + job.salary + '<strong></span</li>');
                    $("#jobs_list").append('<li data-role="list-divider">Average salary for related jobs</li>');
                } else if (i < data.length-1) {
                    // last two items are timestamps
                    $("#jobs_list").append('<li><h3>' + job.title + '</h3><span class="ui-li-aside">' + job.salary + '</span</li>');
                }
            });
            $("#jobs_list").listview('refresh');     
        });
    }
}

 $("#tag_detail").on('pagebeforeshow', function( event ) {

    if (!curTag) {  // returning from external web page
        curTag = localStorage.getItem('curTag'); 
    }

    var fullTag = getTag(curTag);
    // populate tag detail page
    $("#title").text(fullTag.title);
    $("#description").text(fullTag.description);

    var strRelated = "";
    if (fullTag.tags) {
        var relatedTags = fullTag.tags.split(",");
        $.each(relatedTags, function(i, tag) {
            strRelated = strRelated.concat('<button>' + tag + '</button>');
        });
    }
    $("#related").html(strRelated);

    // populate tag resources list page
    $("#resource_list").append('<li data-role="list-divider">Resources</li>');
    $.each(resourceLinks, function(i, resource) {

        var link = resource.link.replace('<tag>',curTag);
        $('#resource_list').append('<li><a href="' + link + '"><h3>' + resource.title + '</h3></a></li>');
    });
    if (fullTag.resources) {

        $.each(fullTag.resources, function(i, resource) {
            $('#resource_list').append('<li><a href="' + resource.link + '"><h3>' + resource.title + '</h3></a></li>');
        });
    }
    $("#resource_list").listview('refresh');

    if (ga) { 
          ga('send', 'event', 'tag', 'details', curTag);
      }


});


$(document).on('pagecontainerchange', function(event, ui){

    if (ga) { 
          ga('send', 'pageview', ui.toPage[0].id);          
    }
});


$(document).on('pageinit', '#tag_detail', function(){

    // clone footer from main page 
    $( "#terms #footer" ).clone().appendTo( "#tag_detail");
});

$(document).on('pageinit', '#tags', function(){

    alltags = localStorage.getItem('alltags');
    if (!alltags) {
        var url = 'http://brisksoft.us/glossary/getterms.php?tag=all';  
        $.getJSON( url, function( data ) {
            alltags = data.Tags;
            localStorage.setItem('alltags', JSON.stringify(alltags));
            updateList(alltags, '#tagslist', '#relatedtags');
        });
    } else {
        alltags = JSON.parse(alltags);
        updateList(alltags, '#tagslist', '#relatedtags');
    }


    $('#tagslist').on('click', 'a', function(e) {
        // store selected tag into global variable for use on detail page
        curTag = this.id;
    });

    // clone footer from main page 
    $( "#terms #footer" ).clone().appendTo( "#tags" );
});

 $("#tags").on('pagebeforeshow', function( event ) {

    filterVal = $( "input:radio[name=tagfilter]:checked" ).val();
    filterTags(filterVal);

});


$(document).on('pageinit', '#jobs', function(){

    // clone footer from main page 
    $( "#terms #footer" ).clone().appendTo( "#jobs");
});

$(document).on('pageinit', '#relatedtags', function(){

    // clone footer from main page 
    $( "#terms #footer" ).clone().appendTo( "#relatedtags");
});

$("#relatedtags").on('pagebeforeshow', function( event ) {

    // populate related tags page
    $("#tag_name").text(curTag);

});

$(document).on('pageinit', '#about', function(){
    // load about page
    $( "#about .ui-content" ).load( "http://localhost/~brenden/BriskSoft/glossary/about.php .ui-content", function() {
                    $("#about .ui-content" ).trigger("create");
    });

    // clone footer from main page 
    $( "#terms #footer" ).clone().appendTo( "#about" );
});
