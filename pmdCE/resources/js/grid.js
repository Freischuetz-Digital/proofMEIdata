/*
 * grid.js
 * 
 * Is responsible for superimposing staff and measure numbers, and sllur highlighting on the facsimile image
 */

var grid = (function() {
    
    var zones = null;
    var page = null;
    
    var gridChangeListeners = [];
    
    
    var init = function() {
        selection.addSelectionChangeListener(onSelectionChanged);
        
        setDimensions();  
    };
    
    var addGridChangeListener = function(listener) {
        gridChangeListeners.push(listener);
    };
    
    //todo: bei resize der Seite aufrufen
    var setDimensions = function() {
        
        var width = $('#facsimileArea img').width();
        var height = $('#facsimileArea img').height();
        
        $('#overlaidLabels').width(width);
        $('#overlaidLabels').height(height);
        
        $('#overlaidItems').width(width);
        $('#overlaidItems').height(height);
    };
    
    var onSelectionChanged = function(sourcePath, sourceSigle, mdivId) {
        
        gridChangeListeners.length = 0;
        
        removeFacsimileLabels();
        
        new jQuery.ajax('resources/xql/getZones.xql', {
            method: 'get',
            data: {path: sourcePath, types: 'all'},
            success: function(result) {
            
                var response = result || '';
                var json = jQuery.parseJSON(response);
                
                zones = json.zones;
                page = json.page;
                
                setDimensions();
                
                $.each(gridChangeListeners, function(index, listener) {
                    listener();
                });
    
                drawFacsimileLabels();
            }
        });
        
    };
    
    var removeSlurs = function() {
      $('#slurBox .slur').off();
      $('#slurBox .slur').remove();
    };
    
    var removeFacsimileLabels = function() {
        $('#overlaidLabels *').off();
        $('#overlaidLabels *').remove();
    };
    
    var removeOverlaidItems = function() {
        $('#overlaidItems *').off();
        $('#overlaidItems *').remove();
    };
    
    var drawFacsimileLabels = function() {
        
        var measureZones = $.grep(zones, function(elem,index) {
            return elem.type === 'measure';
        });
        
        var allStaffZones = $.grep(zones, function(elem,index) {
            return elem.type === 'staff';
        });
        
        var maxStaffN = allStaffZones.length / measureZones.length;
        
        console.log('found ' + measureZones.length + ' measures, which should have ' + maxStaffN + ' staves');
        
        var firstStaves = new Array();
        
        for(i=1;i<=maxStaffN;i++) {
            
            var staffZones = $.grep(allStaffZones, function(elem,index) {
                return elem.n == i;
            });
            
            var firstStaffZone = staffZones[0];
            for(j=1;j<staffZones.length;j++) {
                if(staffZones[j].ulx < firstStaffZone.ulx)
                    firstStaffZone = staffZones[j];
            };
            
            firstStaves.push(firstStaffZone);  
        };
        
        $.each(firstStaves, function(index,elem){
            
            var tmpl = $('#templates .facsimileLabel').clone();
            
            var right = 100 - (elem.ulx / page.width * 100);
            var top = elem.uly / page.height * 100;
            
            //tmpl.css('right', right + '%');
            tmpl.css('left','0');
            tmpl.css('top',top + '%');
            
            tmpl.text(elem.n);
            
            $('#overlaidLabels').append(tmpl);
        });
        
        $.each(measureZones, function(index,elem){
            
            var tmpl = $('#templates .facsimileLabel').clone();
            
            var left = elem.ulx / page.width * 100;
            var bottom = 100 - (elem.uly / page.height * 100);
            
            tmpl.css('left', left + '%');
            tmpl.css('bottom',bottom + '%');
            
            tmpl.text(elem.n);
            
            $('#overlaidLabels').append(tmpl);
        });
    };
    
    //todo: dürfte in der aktuellen Version nicht gecallt werden, ursprünglich zum Zeichnen eines Slurs über den relevanten staves
    var drawSlur = function(firstMeasureID, lastMeasureID, staff, curvedir, ID) {
        
        var firstIndex = grid.measureIDs.indexOf(firstMeasureID);
        var lastIndex = grid.measureIDs.indexOf(lastMeasureID);
        
        var measureIDs = $.grep(grid.measureIDs, function(elem,index) {
            return  (firstIndex <= index) && (index <= lastIndex);
        });
        
        var fullRow = $.grep(grid.staves, function(elem, index) {
            return elem.staffN == staff; 
        });
        
        var zones = $.grep(fullRow, function(elem, index) {
            return measureIDs.indexOf(elem.measureID) > -1;
        });
        
        if(zones.length < 1) {
            console.log('something went wrong with the number of measures');
            return null;
        }
        
        var min_ulx = grid.width;
        var min_uly = grid.height;
        var max_lrx = 0;
        var max_lry = 0;
        
        $.each(zones, function(index,elem) {
           if(elem.ulx < min_ulx) min_ulx = elem.ulx;
           if(elem.uly < min_uly) min_uly = elem.uly;
           if(elem.lrx > max_lrx) max_lrx = elem.lrx;
           if(elem.lry > max_lry) max_lry = elem.lry;
        });
        
        var ulx = min_ulx / grid.width * 102.5;
        var uly = (0.55*min_uly + 0.45*max_lry) / grid.height * 100;
        var lrx = 100 - (max_lrx / grid.width * 97.5);
        var lry = 100 - (max_lry / grid.height * 100);
        
        var tmpl = $('#templates .slur').clone();
        tmpl.css('left',ulx + '%');
        tmpl.css('top',uly + '%');
        tmpl.css('right',lrx + '%');
        //tmpl.css('bottom',lry + '%');
        tmpl.addClass(curvedir);
        tmpl.attr('title',ID);
        tmpl.on('click',function(){
            alert('observing slur ' + ID);
        });
        
        console.log(tmpl);
        console.log($('#slurBox'));
        
        $('#slurBox').append(tmpl);
        
    };
    
    //todo: wird das benutzt?
    var highlightRect = function(zoneID,position,onClickFunc) {
        
        var zone = $.grep(zones, function(elem, index) {
            return elem.targetID == zoneID;
        })[0];
        
        var tmpl = $('#templates .zoneMarker').clone();
        
        if(zone == null || zone.length === 0)
            return;
        
        if(position === 'start') {
            
            var right = 100 - (zone.ulx / page.width * 100);
            tmpl.css('right', right + '%');
            tmpl.addClass('start');
            
        } else if(position === 'end') {
            
            var left = zone.lrx / page.width * 100;
            tmpl.css('left', left + '%');
            tmpl.addClass('end');
            
        } else {
            return;
        }
        
        var top = zone.uly / page.height * 100;
        var bottom = 100 - (zone.lry /page.height * 100);
        
        tmpl.css('top',top + '%');
        tmpl.css('bottom',bottom + '%');
        
        tmpl.on('click',onClickFunc);
        
        $('#overlaidItems').append(tmpl);
            
    };
    
    var showAllStaves = function(onClickFunc) {
        
        var zoneArray = $.grep(zones, function(elem, index) {
            return elem.type === 'staff';
        });
        
        for(var i=0;i<zoneArray.length;i++) {
            var zone = zoneArray[i];
            
            var tmpl = $('#templates .zoneButton').clone();
            var top = (zone.uly / 2 + zone.lry / 2) / page.height * 100;
            var left = (zone.lrx / 2 + zone.ulx / 2) / page.width * 100;
            
            tmpl.css('top',top + '%');
            tmpl.css('left', left + '%');
            tmpl.attr('title',zone.targetID);
            tmpl.on('click',onClickFunc);
            
            $('#overlaidItems').append(tmpl);
        }
    };
    
    //todo: wird das benutzt?
    var showRect = function(firstMeasureID, lastMeasureID, firstStaff, lastStaff) {
        
        
        var firstIndex = grid.measureIDs.indexOf(firstMeasureID);
        var lastIndex = grid.measureIDs.indexOf(lastMeasureID);
        
        var measureIDs = $.grep(grid.measureIDs, function(elem,index) {
            return  (firstIndex <= index) && (index <= lastIndex);
        });
        
        if(firstStaff > lastStaff) {
            console.log('Function showRect() used incorrectly: param lastStaff is smaller than param firstStaff! Execution aborted.');
            return null;
        }
        
        var fullRow = $.grep(grid.staves, function(elem, index) {
            return (firstStaff <= elem.staffN) && (elem.staffN <= lastStaff); 
        });
        
        var zones = $.grep(fullRow, function(elem, index) {
            return measureIDs.indexOf(elem.measureID) > -1;
        });
        
        if(zones.length < 1) {
            console.log('something went wrong with the number of measures');
            return null;
        }
        
        var min_ulx = grid.width;
        var min_uly = grid.height;
        var max_lrx = 0;
        var max_lry = 0;
        
        $.each(zones, function(index,elem) {
           if(elem.ulx < min_ulx) min_ulx = elem.ulx;
           if(elem.uly < min_uly) min_uly = elem.uly;
           if(elem.lrx > max_lrx) max_lrx = elem.lrx;
           if(elem.lry > max_lry) max_lry = elem.lry;
        });
        
        var ulx = min_ulx / grid.width * 100;
        var uly = min_uly / grid.height * 100;
        var lrx = 100 - (max_lrx / grid.width * 100);
        var lry = 100 - (max_lry / grid.height * 100);
        
        var tmpl = $('#templates .staffHighlight').clone();
        tmpl.css('left',ulx + '%');
        tmpl.css('top',uly + '%');
        tmpl.css('right',lrx + '%');
        tmpl.css('bottom',lry + '%');
        
        $('#highlightArea').append(tmpl);
        
    };
    
    var unhighlight = function() {
        $('#overlaidItems *').off();
        $('#overlaidItems *').remove();
    };
    
    return {
        init: init,
        addGridChangeListener: addGridChangeListener,
        showRect: showRect,
        unhighlight: unhighlight,
        drawSlur: drawSlur,
        setDimensions: setDimensions,
        highlightRect: highlightRect,
        showAllStaves: showAllStaves
    };
    
})();