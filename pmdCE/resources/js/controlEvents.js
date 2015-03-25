/*
 * controlevents.js
 * 
 * - load controlEvents for page from database
 * - add new events
 * - append HTML to controlEvent list
 * - select controlEevent from controlEvent list
 * 
 */
var controlevents = (function(){
    
    var init = function() {
        selection.addSelectionChangeListener(onSelectionChanged);
        
        $('#addModal').on('show.bs.modal', function (e) {
            if(currentSourcePath === null) return e.preventDefault(); // stops modal from being shown when no controlEvent is selected
            
        });
        
        $('#addModal button.btn-success').on('click',function() {
            var type = $('#addModal input:checked').val();
            addNewEvent(type, currentSourcePath);
        });
    };
    
    var controlEvents = [];
    var currentEvent = null;
    var currentSourcePath = null;
    
    var controleventChangeListeners = [];
    
    var addControleventChangeListener = function(listener) {
        controleventChangeListeners.push(listener);
    };
    
    var onSelectionChanged = function(sourcePath, sourceSigle, mdivId) {
        
        new jQuery.ajax('resources/xql/getControlEvents.xql', {
            method: 'get',
            data: {path: sourcePath},
            success: function(result) {
                var response = result || '';
                var json = jQuery.parseJSON(response);
                console.log('json');
                console.log(json);
                controlEvents = json;
                console.log('controlEvents')
                console.log(controlEvents);
                currentSourcePath = sourcePath;
                
                $('#slurDiv tr.slurRow').off();
                $('#slurDiv tr.slurRow').remove();
                $('#slurTab').text('slurs (' + json.slurs.length + ')');
                
                //todo: andere ce implementieren
                $.each(json.slurs, function(index, slur) {
                   loadSlur(slur); 
                });
                
                loadHairpins(json.hairpins);
                loadDynams(json.dynams);
                loadDirs(json.dirs);
                
                
            }
        });
    };
    
    var getControlEvent = function(){
      return (controlEvent !== null) ? controlEvent : 'nüscht';
    };
    
    var getControlEvents = function(){
      return controlEvents;
    };
    
    var updateControlEventProperty = function(id, type, property, val){
      console.log('controlevents.updateControlEventProperty start');
      console.log(property);
      console.log(val);
      var propertyType = getPropertyType(property);
      $.map(getControlEvents()[type+'s'], function(item,index){
        if(item.id === id){
          switch(propertyType){
            case 'string':
              getControlEvents()[type+'s'][index][property] = val;
              break;
            case 'array':
              //getControlEvents()[type+'s'][index][property] = [];
              $.each(val, function(index,value){
                if($.inArray(value, controlevents.getControlEvents()[type+'s'][index][property]) == -1){
                  controlevents.getControlEvents()[type+'s'][index][property].push(value);
                };
              });
              break;
            case 'boolan':
              getControlEvents()[type+'s'][index][property] = val;
              break;
          }
        }
      });
    };
    
    var addNewEvent = function(type,sourcePath) {
        
        var obj = new Object();
        //doc: generiert unique ID…
        obj.id = type + '_' + 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);return v.toString(16);});
        obj.type = type;
        obj.startIDs = new Array();
        obj.tstamp = '';
        obj.tstamp2 = '';
        obj.startStaffID = '';
        obj.staff = '';
        
        if(type === 'slur') {
            obj.endIDs = new Array();
            obj.endStaffID = '';
            obj.endPageName = String(sourcePath).split('/').pop(-1);
            obj.curvedir = 'above';
            
            editor.getTemplate(type,obj.id);
            loadSlur(obj, true);
        }
        
        guiEditor.loadControlEvent(obj,sourcePath);
        
        console.log('created new ' + type + ' on page ' + sourcePath + 'with id="' + obj.id + '"');
    };
    
    //doc: ein CE aus der Liste aktivieren 
    var setCurrentEvent = function(json) {
        
        console.log('current event is: ' + json.id + ' (' + json.type + ')');
        
        if(['slur','hairpin','dynam','dir'].indexOf(json.type) == -1) {
            console.log('trying to load unknown control event (xml:id: ' + json.id + '/ type: ' + json.type + ')')
        }
        
        $.each(controleventChangeListeners, function(index, listener) {
            listener(currentSourcePath, json.id);
        });
        
        guiEditor.loadControlEvent(json,currentSourcePath);
        
    };
    
    //doc: ein element in die Liste laden
    var loadSlur = function(slur, created) {
        
        var placement = '';
        if(slur.tstamp === '' && slur.startIDs.length === 1 && slur.endIDs.length === 1)
            placement = 'obvious';
        else if(slur.startIDs.length === 1 && slur.endIDs.length === 1)
            placement = 'ambiguous';
        else
            placement = 'multiResolve';
        
        var tmpl = jQuery('#templates tr.slurRow').clone();
        
        if(typeof created != 'undefined')
            tmpl.attr('data-new', true);
        
        tmpl.attr('id','tableRow_' + slur.id);
        tmpl.children('.staff').text(slur.staff);
        
        if(slur.startIDs.length >= 1 && slur.startIDs[0].length >= 1)
            tmpl.children('.startLabel').text(slur.startIDs[0]);
        if(slur.endIDs.length >= 1 && slur.endIDs[0].length >= 1)
            tmpl.children('.endLabel').text(slur.endIDs[0]);
        
        tmpl.children('.curvedir').text(slur.curvedir);
        
        tmpl.children('.type').children('.cePlacement').addClass(placement);
        
        tmpl.on('click',function(){
            setCurrentEvent(slur);
        });
        /*
        tmpl.on('mouseout',function(){
            grid.unhighlight();
        });*/
        
        $('#slurDiv tbody').append(tmpl);
        
        //$('#slurDiv').change();
        
    };
    
    var loadHairpins = function(hairpins) {
        
        $('#hairpinDiv tr.hairpinRow').off();
        $('#hairpinDiv tr.hairpinRow').remove();
        
        $('#hairpinTab').text('hairpins (' + hairpins.length + ')');
        
        $.each(hairpins, function(index, value) {
            
            var tmpl = jQuery('#templates tr.hairpinRow').clone();
            tmpl.attr('id',value.id);
            tmpl.children('.staff').text(value.staff);
            tmpl.children('.startLabel').text(value.startLabel);
            tmpl.children('.startLabel').attr('id',value.measureID);
            tmpl.children('.endLabel').text(value.endLabel);
            tmpl.children('.endLabel').attr('id',value.endMeasureID);
            tmpl.children('.curvedir').text(value.curvedir);
            
            /*tmpl.on('mouseover',function(){
                grid.showRect(value.measureID,value.endMeasureID,value.staff,value.staff);
            });
            
            tmpl.on('mouseout',function(){
                grid.unhighlight();
            });*/
            
            $('#hairpinDiv tbody').append(tmpl);
        });
        
        $('#hairpinDiv').change();
        
    };
    
    var modifyHairpins = function(json) {
        console.log('modifyHairpins');  
        
    };
    
     var loadDynams = function(dynams) {
        
        $('#dynamDiv tr.dynamRow').off();
        $('#dynamDiv tr.dynamRow').remove();
        
        $('#dynamTab').text('dynams (' + dynams.length + ')');
        
        $.each(dynams, function(index, value) {
            
            var tmpl = jQuery('#templates tr.dynamRow').clone();
            tmpl.attr('id',value.id);
            tmpl.children('.staff').text(value.staff);
            tmpl.children('.startLabel').text(value.startLabel);
            tmpl.children('.startLabel').attr('id',value.measureID);
            tmpl.children('.endLabel').text(value.endLabel);
            tmpl.children('.endLabel').attr('id',value.endMeasureID);
            tmpl.children('.curvedir').text(value.curvedir);
            
            /*tmpl.on('mouseover',function(){
                grid.showRect(value.measureID,value.endMeasureID,value.staff,value.staff);
            });
            
            tmpl.on('mouseout',function(){
                grid.unhighlight();
            });*/
            
            $('#dynamDiv tbody').append(tmpl);
        });
        
        $('#dynamDiv').change();
        
    };
    
    var modifyDynams = function(json) {
        console.log('modifyDynams');  
        
    };
    
    var loadDirs = function(dirs) {
        
        $('#dirDiv tr.dirRow').off();
        $('#dirDiv tr.dirRow').remove();
        
        $('#dirTab').text('dirs (' + dirs.length + ')');
        
        $.each(dirs, function(index, value) {
            
            var tmpl = jQuery('#templates tr.dirRow').clone();
            tmpl.attr('id',value.id);
            tmpl.children('.staff').text(value.staff);
            tmpl.children('.startLabel').text(value.startLabel);
            tmpl.children('.startLabel').attr('id',value.measureID);
            tmpl.children('.endLabel').text(value.endLabel);
            tmpl.children('.endLabel').attr('id',value.endMeasureID);
            tmpl.children('.curvedir').text(value.curvedir);
            
            /*tmpl.on('mouseover',function(){
                grid.showRect(value.measureID,value.endMeasureID,value.staff,value.staff);
            });
            
            tmpl.on('mouseout',function(){
                grid.unhighlight();
            });*/
            
            $('#dirDiv tbody').append(tmpl);
        });
        
        $('#dirDiv').change();
        
    };
    
    var modifyDirs = function(json) {
        console.log('modifyDirs');  
        
    };
    
    var removeControlEvent = function(eventID) {
        $('#tableRow_' + eventID).off();
        $('#tableRow_' + eventID).remove();
        
        console.log('removedFromList');
    };
    
    var highlightRow = function(eventID,style) {
        removeHighlightRow();
        $('#tableRow_' + eventID).addClass(style);
    };
    
    var removeHighlightRow = function() {
        $('.tab-content table tr.info').removeClass('info');
    };
    
    var highlightCell = function(eventID,cellSelector,style) {
        removeHighlightCell(eventID,cellSelector,style);
        $('#tableRow_' + eventID + cellSelector).addClass(style);
    };
    
    var removeHighlightCell = function(eventID,cellSelector,style) {
        $('#tableRow_' + eventID + cellSelector).removeClass(style);
    };
    
    var updateCellValue = function(eventID,propertyType,cellSelector,val){
        switch(propertyType){
          case 'string':
            $('#tableRow_' + eventID + cellSelector).text(val);
            break;
          case 'array':
            $('#tableRow_' + eventID + cellSelector).text(val[0]);
            break;
          case 'boolean':
            $('#tableRow_' + eventID + cellSelector).text(val);
            break;            
        }
    };
    
    var updateProperty = function(eventID,type,property,val){
        var cellSelector = getCellSelector(property);
        var propertyType = getPropertyType(property);
        updateCellValue(eventID,propertyType,cellSelector,val);
        highlightCell(eventID,cellSelector,'danger');
        updateControlEventProperty(eventID, type, property, val);

    };
    
    var getCellSelector = function(property){
      var cellSelector;
      switch(property){
        case 'staff':
          cellSelector = ' td.staff';
          break;
        case 'startIDs':
          cellSelector = ' td.startLabel';
          break;
        case 'endIDs':
          cellSelector = ' td.endLabel';
          break;
        case 'curvedir':
          cellSelector = ' td.curvedir';
          break;
        case 'placement':
          cellSelector = ' td.type';
          break;
        //not in controlevents list
        case 'tstamp':
          cellSelector = cellSelector;
          break;
        case 'tstamp2':
          cellSelector = cellSelector;
          break;  
        case 'type':
          cellSelector = cellSelector;
          break;
        case 'xml':
          cellSelector = cellSelector;
          break;
        case 'docUri':
          cellSelector = cellSelector;
          break;
        case 'id':
          cellSelector = cellSelector;
          break;
        case 'startStaffID':
          cellSelector = cellSelector;
          break;
        case 'endStaffID':
          cellSelector = cellSelector;
          break;
        case 'XXX':
          cellSelector = 'marked';
          break;
      }
      return cellSelector;
    };
    
    var getPropertyType = function(property){
      var propertyType;
      switch(property){
        case 'staff':
          propertyType = 'string';
          break;
        case 'startIDs':
          propertyType = 'array';
          break;
        case 'endIDs':
          propertyType = 'array';
          break;
        case 'curvedir':
          propertyType = ' string';
          break;
        case 'placement':
          propertyType = 'string';
          break;
        //not in controlevents list
        case 'tstamp':
          propertyType = 'string';
          break;
        case 'tstamp2':
          propertyType = 'string';
          break;  
        case 'type':
          propertyType = 'string';
          break;
        case 'xml':
          propertyType = 'string';
          break;
        case 'docUri':
          propertyType = 'string';
          break;
        case 'id':
          propertyType = 'string';
          break;
        case 'startStaffID':
          propertyType = 'string';
          break;
        case 'endStaffID':
          propertyType = 'string';
          break;
        case 'marked':
          propertyType = 'string';
          break;
        case 'changed':
          propertyType = 'boolean';
          break;
      }
      return propertyType;
    };
    
    return {
        init: init,
        addControleventChangeListener: addControleventChangeListener,
        removeControlEvent: removeControlEvent,
        highlightRow: highlightRow,
        removeHighlightRow: removeHighlightRow,
        getControlEvent: getControlEvent,
        getControlEvents: getControlEvents,
        updateControlEventProperty: updateControlEventProperty,
        updateProperty: updateProperty
    }
})();