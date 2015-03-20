/* 
 * This file is responsible for loading the page navigation and the facsimile
 * and initializing all other components
 */

//Baustelle, nicht in Benutzung und (so) nicht funktionsfähig
// Tool for retrieving URL Parameters, taken from http://jquery-howto.blogspot.de/2009/09/get-url-parameters-values-with-jquery.html

$.extend({
  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
});


// Patch for dropdown menus with Bootstrap 3

$(document.body).on( 'click', '.dropdown-menu li', function( event ) {
 
   var $target = $( event.currentTarget );
 
   $target.closest( '.dropdown' )
      .find( '[data-bind="label"]' ).text( $target.text() )
         .end()
      .children( '.dropdown-toggle' ).dropdown( 'toggle' );
   
// trigger for pmd change event

    selection.menuTrigger($target);
   
   
   return false;
 
});

/*  
 *  proofMEIdata Javascript library
 *  ControlEvent Tool
 *
 *  Author: Johannes Kepper
 * 
 */
 
 $(document).ready(function() {
    
    selection.init(); //Auswahl der Seite --> toolbar
    facsimile.init();
    controlevents.init(); //Liste mit CE rechts, einiges an Verwaltung
    grid.init(); //"Raster" der staves auf dem Faksimile (prüfen) 
    
    editor.init(); //XML editor
    guiEditor.init(); //graphische Editor rechts unten
    
    selection.load();
});


var selection = (function() {

    var navigation = null;
    var lockReload = null;
    
    var selectionChangeListeners = [];

    var init = function() {
        $('#btnPrevPage').on("click", prevPage);
		$('#btnNextPage').on("click", nextPage);	
    };
    
    // load navigation bar
    var load = function() {
        new jQuery.ajax('resources/xql/pmd_ce_getNavigation.xql', {
            method: 'get',
            success: function(result) {
                navigation = jQuery.parseJSON(result);
                
                setSources();
            }
        });
    };
    
    var menuTrigger = function(elem) {
        if(elem.hasClass('source'))
            onChangeSources();
        if(elem.hasClass('mdiv'))
            onChangeMdivs();
        if(elem.hasClass('page'))
            onChangePages();
    };
    
    var loadContents = function() {
        
        var params = getSelectedStaffParameters();
        
        $.each(selectionChangeListeners, function(index, listener) {
            listener(params.sourcePath, params.sourceSigle, params.mdivId);
        });
    };
    
    var nextPage = function() {
    
        //todo: check if a page is loaded already, otherwise return null
        
        console.log('nextPage');
        
        var pageID = 'page_' + $('#currentPage').text();
        var pageIndex = $('#availPages .data_entry').index($('#availPages #' + pageID));
    
        if(pageIndex == $('#availPages .data_entry').length - 1) return;
        
        $('#availPages .data_entry')[pageIndex+1].click();
    };
    
    var prevPage = function() {
    
        //todo: check if a page is loaded already, otherwise return null
    
        console.log('prevPage');
    
        var pageID = 'page_' + $('#currentPage').text();
        var pageIndex = $('#availPages .data_entry').index($('#availPages #' + pageID));
    
        if(pageIndex === 0) return;
        
        $('#availPages .data_entry')[pageIndex-1].click();
    };
    
    var onChangeSources = function() {
        var sigle = $("#currentSource").text();
        
        var selected = $('#source_' + sigle);
        var sourceIndex = $('#availSources .data_entry').index(selected);
        
        setMdivs(sourceIndex);
    };
    
    var onChangeMdivs = function() {
    
        var mov = $('#currentMdiv').text();
        var sigle = $("#currentSource").text();
    
        var selected = $('#mdiv_' + mov);
        var mdivIndex = $('#availMdivs .data_entry').index(selected);
                
        selected = $('#source_' + sigle);
        var sourceIndex = $('#availSources .data_entry').index(selected);
        
        lockReload = 1;
        
        setPages(sourceIndex, mdivIndex);
    };
    
    var onChangePages = function() {
        lockReload--;
                
        if(lockReload <= 0) loadContents();
    };
    
    var setSources = function() {
    
        $('#availSources .data_entry').off();
        $('#availSources .data_entry').remove();
        
        $.each(navigation, function(index, value) {
            var sigle = value.sigle.replace(/KA/,'K<sup>A</sup>').replace(/(\d+)/,'<sub>$1</sub>');
        
            $('#availSources').append('<li class="data_entry source" id="source_' + value.sigle + '"><a>' + sigle + '</a></li>');
        });
        
        /*$('#availSources .data_entry')[0].click();
        $('#availSources .data_entry')[0].click();
        */
        
        $('#availSources').change();
        
        var sourceParam = $.getUrlVar('source');
        if(navigation.indexOf(sourceParam) != '-1')
            alert('I know this source: ' + sourceParam);
    };
    
    var setMdivs = function(sourceIndex) {
    
        if(sourceIndex === -1)
            return;
    
        $('#availMdivs .data_entry').off();
        $('#availMdivs .data_entry').remove();
        
        $.each(navigation[sourceIndex].mdivs, function(index, value) {
            
            $('#availMdivs').append('<li class="data_entry mdiv" id="mdiv_' + value.id + '"><a>' + value.id + '</a></li>');
        });
        
        /*$('#availMdivs .data_entry')[0].click();
        $('#availMdivs .data_entry')[0].click();
        */
        $('#availMdivs').change();
    };
    
    var setPages = function(sourceIndex, mdivIndex) {
    
        if(sourceIndex === -1 || mdivIndex === -1)
            return;
    
        $('#availPages .data_entry').off();
        $('#availPages .data_entry').remove();
        
        $.each(navigation[sourceIndex].mdivs[mdivIndex].pages, function(index, value) {
            
            $('#availPages').append('<li class="data_entry page" id="page_' + value.id + '"><a>' + value.id + '</a></li>');
        });
        
        /*$('#availPages .data_entry')[0].click();
        $('#availPages .data_entry')[0].click();
        */
        $('#availPages').change();
    };
    
    var addSelectionChangeListener = function(listener) {
        selectionChangeListeners.push(listener);
    };

    var getSelectedStaffParameters = function() {
    
        var sourceID = 'source_' + $('#currentSource').text();
        var sourceIndex = $('#availSources .data_entry').index($('#availSources #' + sourceID));
        
        var mdivID = 'mdiv_' + $('#currentMdiv').text();
        var mdivIndex = $('#availMdivs .data_entry').index($('#availMdivs #' + mdivID));
        
        var pageID = 'page_' + $('#currentPage').text();
        var pageIndex = $('#availPages .data_entry').index($('#availPages #' + pageID));
        
        console.log('indizes: ' + sourceIndex + ' / ' + mdivIndex + ' / ' + pageIndex);
        
        if(sourceIndex === -1 || mdivIndex === -1 || pageIndex === -1)
            return;
        
        var sourcePath = navigation[sourceIndex].mdivs[mdivIndex].pages[pageIndex].id;
        var sourceSigle = navigation[sourceIndex].sigle;
        var mdivId = navigation[sourceIndex].mdivs[mdivIndex].id;
        
        return {
            sourcePath: sourcePath,
            sourceSigle: sourceSigle,
            mdivId: mdivId
        };
    };

    return {
        init: init,
        load: load,
        menuTrigger: menuTrigger,
        addSelectionChangeListener: addSelectionChangeListener,
        getSelectedStaffParameters: getSelectedStaffParameters
    };
})();

var facsimile = (function() {

    var init = function() {
    
        //todo
        $('#facsZout').on("click", zoomOut);
		$('#facsUp').on("click", moveUp);	
		$('#facsZin').on("click", zoomIn);
		$('#facsLeft').on("click", moveLeft);	
		$('#facsDown').on("click", moveDown);
		$('#facsRight').on("click", moveRight);	
    
    selection.addSelectionChangeListener(onSelectionChanged);
      
      $('#facsimileArea img').load(function(){
          imageLoaded();
        });
    };
    
    var imageLoaded = function(){
     grid.drawFacsimileLabels();
     grid.setDimensions();
    };

    var zoomOut = function() {
        $('#facsimileArea img').css('maxWidth','100%');
        $('#facsimileArea img').css('width','100%');
        
        $('#overlaidItems').css('maxWidth','100%');
        $('#overlaidItems').css('width','100%');
        
        $('#overlaidLabels').css('maxWidth','100%');
        $('#overlaidLabels').css('width','100%');
        
        grid.setDimensions();
    };
    
    var zoomIn = function() {
        $('#facsimileArea img').css('maxWidth','200%');
        $('#facsimileArea img').css('width','200%');
        
        $('#overlaidItems').css('maxWidth','200%');
        $('#overlaidItems').css('width','200%');
        
        $('#overlaidLabels').css('maxWidth','200%');
        $('#overlaidLabels').css('width','200%');
        
        grid.setDimensions();
    };
    
    var moveUp = function() {
        $('#facsimileArea img').css('top','+=30');
        
        $('#overlaidItems').css('top','+=30');
        $('#overlaidLabels').css('top','+=30');
        
        grid.setDimensions();
    };
    
    var moveRight = function() {
        $('#facsimileArea img').css('left','-=30');
        
        $('#overlaidItems').css('left','-=30');
        $('#overlaidLabels').css('left','-=30');
        
        grid.setDimensions();
    };
    
    var moveDown = function() {
        $('#facsimileArea img').css('top','-=30');
        
        $('#overlaidItems').css('top','-=30');
        $('#overlaidLabels').css('top','-=30');
        
        grid.setDimensions();
    };
    
    var moveLeft = function() {
        $('#facsimileArea img').css('left','+=30');
        
        $('#overlaidItems').css('left','+=30');
        $('#overlaidLabels').css('left','+=30');
        
        grid.setDimensions();
    };

    var onSelectionChanged = function(sourcePath, sourceSigle, mdivId) {
        
        new jQuery.ajax('resources/xql/pmd_ce_getFacsimilePage.xql', {
            method: 'get',
            data: {path: sourcePath},
            success: function(result) {
                var response = result || '';
                $('#facsimileArea img').attr('src', response);
                //$('#facsimileArea a').attr('href', response.replace(/\.jpg\?.*$/, '.jpg?dw=1200&amp;amp;mo=rawfile'));
            }
        });
    };

    return {
        init: init
    };
})();
