var guiEditor = (function() {
    
    var controlEvent = null;
    var renderer = new verovio.toolkit();
    
    var startPrefix;
    var endPrefix;
    
    var sourcePath;
    
    var currentStarts = new Array();
    var currentEnds = new Array();
    
    var tstamp = '';
    var tstamp2 = '';
    
    var placement;      // --> obvious | ambiguous | multiResolve
    
    var changedArray = new Array();
    
    //todo: selection.addSelectionChangeListener
    
    var init = function() {
        
        $('#saveButton').on('click',function(event){
            save();
        });
        
        $('#removeModal').on('show.bs.modal', function (e) {
            if(controlEvent === null) return e.preventDefault(); // stops modal from being shown when no controlEvent is selected
            
            $('#removeModal .ceType').text(controlEvent.type);
            $('#removeModal .ceID').text(controlEvent.id);
            
        });
        
        $('#removeButton').on('click',deleteControlEvent);
    
        selection.addSelectionChangeListener(onSelectionChanged);
    };
    
    var onSelectionChanged = function(sourcePath, sourceSigle, mdivId) {
        
        if(controlEvent != null) {
            storeControlEvent();
            unloadControlEvent();
        }
    };
    
    var loadControlEvent = function(json,path) {
        
        if(controlEvent != null) {
            storeControlEvent();
            unloadControlEvent();
        }
        
        //console.log('guiEditor.loadControlEvent(' + json.id + ', ' + path + ')');
        
        controlEvent = json;
        sourcePath = path;
        
        startPrefix = controlEvent.type + 'Start___';
        endPrefix = controlEvent.type + 'End___';
        
        controlevents.highlightRow(controlEvent.id);
        
        //todo: auf andere CE anpassen
        $('#slurTstamp').val(controlEvent.tstamp);
        $('#slurTstamp2').val(controlEvent.tstamp2);
        
        getRendering('start');
        
        if(controlEvent.type === 'slur' || controlEvent.type === 'hairpin')
            getRendering('end');
        
        if(controlEvent.tstamp === '' && controlEvent.startIDs.length === 1 && controlEvent.endIDs.length === 1)
            placement = 'obvious';
        else if(controlEvent.startIDs.length === 1 && controlEvent.endIDs.length === 1)
            placement = 'ambiguous';
        else
            placement = 'multiResolve';
        
        
        $('#' + controlEvent.type + 'Placement .cePlacement').removeClass('obvious');
        $('#' + controlEvent.type + 'Placement .cePlacement').removeClass('ambiguous');
        $('#' + controlEvent.type + 'Placement .cePlacement').removeClass('multiResolve');
        $('#' + controlEvent.type + 'Placement .cePlacement').addClass(placement);
        
        var startStaffFunc = function() {
            grid.showAllStaves(setStartStaff);    
        };
        var endStaffFunc = function() {
            grid.showAllStaves(setEndStaff);    
        };
        
        $('#' + controlEvent.type + 'Tools .glyphicon-chevron-right').on('click',startStaffFunc);
        $('#' + controlEvent.type + 'Tools .glyphicon-chevron-left').on('click',endStaffFunc);
        
        if(controlEvent.type === 'slur') {
            
            $('#slurTstamp').on('change', function(event) {
                
                $('#slurTstamp').parent().removeClass('has-error').removeClass('has-warning');
                
                var regex = /^(\d+(\.\d+)?)?$/;
                var val = $(this).val();
                var correct = regex.test(val);
                
                if(correct) {
                    //console.log('This is a correct @tstamp: ' + val);
                    controlEvent.tstamp = val;
                    if(controlEvent.tstamp2 !== '')
                        editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
                    else
                        $('#slurTstamp2').parent().addClass('has-warning');
                    
                } else {
                    $('#slurTstamp').parent().addClass('has-error');
                }
            });
            
            $('#slurTstamp2').on('change', function(event) {
                
                $('#slurTstamp2').parent().removeClass('has-error').removeClass('has-warning');
                
                var regex = /^(\d+m\+\d+(\.\d+)?)?$/;
                var val = $(this).val();
                var correct = regex.test(val);
                
                if(correct) {
                    //console.log('This is a correct @tstamp2: ' + val);
                    controlEvent.tstamp2 = val;
                    if(controlEvent.tstamp !== '')
                        editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
                    else
                        $('#slurTstamp').parent().addClass('has-warning');
                } else {
                    $('#slurTstamp2').parent().addClass('has-error');
                }
            });
        }
        
        
        if(controlEvent.curvedir != undefined) {
            if(controlEvent.curvedir === 'above') 
                $('#' + controlEvent.type + 'Curvedir').val('above');
            else if(controlEvent.curvedir === 'below') 
                $('#' + controlEvent.type + 'Curvedir').val('below');
                
            $('#' + controlEvent.type + 'Curvedir').on('change',function(e){
                var target = e.currentTarget;
                console.log('changing curvedir to ' + $(target).val());
                $('#tableRow_' + controlEvent.id + ' td.curvedir').text($(target).val());
                editor.setAttribute('curvedir', $(target).val());
            });
                
        }
        
        setStartEndListeners();
        
        
    };
    
    var setStartStaff = function(elem) {
        grid.unhighlight();
        
        var staffID = $(this).attr('title');
        controlEvent.startStaffID = staffID;
        
        getRendering('start');
        setStartEndListeners();
        
    };
    
    var setEndStaff = function(elem) {
        grid.unhighlight();
        
        var staffID = $(this).attr('title');
        controlEvent.endStaffID = staffID;
        
        getRendering('end');
        setStartEndListeners();
    };
    
    var setStartEndListeners = function() {
        var onClickFuncStart = function(){
            grid.showAllStaves(setStartStaff);
        };
        
        var onClickFuncEnd = function(){
            grid.showAllStaves(setEndStaff);
        };
        
        grid.highlightRect(controlEvent.startStaffID,'start', onClickFuncStart);
        grid.highlightRect(controlEvent.endStaffID,'end', onClickFuncEnd);
    };
    
    var unloadControlEvent = function() {
        
        controlevents.removeHighlight();
        
        $('#slurCurvedir').off();
        grid.unhighlight();
        editor.setBlank();
        
        $('#' + controlEvent.type + 'Tools .glyphicon-chevron-right').off();
        $('#' + controlEvent.type + 'Tools .glyphicon-chevron-left').off();
        
        $('#slurTstamp').off();
        $('#slurTstamp2').off();
        $('#slurTstamp').val('');
        $('#slurTstamp2').val('');
        
        $('g.note, g.rest').off();
        $('#slurStartBox').html('');
        $('#slurEndBox').html('');
        
        /*controlEvent = null;
        currentStarts.length = 0;
        currentEnds.length = 0;
        tstamp = '';
        tstamp2 = '';*/
        startPrefix = '';
        endPrefix = '';
        placement = '';
    
        sourcePath = '';
        controlEvent = null;
    };
    
    //TODO: PRÜFEN, OB DAS WIRKLICH SO GEHT
    //TODO: was passieren muss, ist dass für jedes Objekt nur ein Change im changedArray vorkommt, dass also bestehende Changes ggf. überschrieben werden
    //also pürfen, ob es im Array schon ein objekt mit gleicher ID gibt und dieses ggf. löschen
    var storeControlEvent = function() {
    
        if(controlEvent === null)
            return;
        
        if(controlEvent.changed != null && controlEvent.changed === true) {
            var obj = new Object();
            
            obj.id = controlEvent.id;
            obj.sourcePath = sourcePath;
            obj.operation = (typeof $('#tableRow_' + obj.id).attr('data-new') != 'undefined'?'create':'change');
            obj.code = editor.getEditorValue();
            
            var pos = -1;
            for(var i = 0; i< changedArray.length;i++) {
                if(changedArray[i].id === obj.id)
                    pos = i;
            }
            
            if(pos === -1)
                changedArray.push(obj);
            else
                changedArray[pos] = obj;
        }
    };
    
    var setChanged = function() {
        controlEvent.changed = true;
        storeControlEvent();
    };
    
    
    var resetNotes = function(elements) {
            
        var regularColor = '#000000';
        
        elements.css('fill',regularColor);
        elements.children().css('stroke',regularColor);
    };
        
    var paintNotes = function(elements,placement) {
        
        var obviousColor = '#3adf00';
        var ambiguousColor = '#ffbf00';
        var multiResolveColor = '#ff8000';
        
        if(placement === 'obvious') {
            elements.css('fill',obviousColor);
            elements.children().css('stroke',obviousColor);
        } else if(placement === 'ambiguous') {
            elements.css('fill',ambiguousColor);
            elements.children().css('stroke',ambiguousColor);
        } else if(placement === 'multiResolve') {
            elements.css('fill',multiResolveColor);
            elements.children().css('stroke',multiResolveColor);
        }
    };
        
    var setNote = function(position,note,mode) {
        
        console.log('setNote(' + position +','+ note.id + ','+ mode + ')');
        
        if((position != 'start' && position != 'end') || (mode != 'add' && mode != 'replace'))
            return;
        
        var noteID = note.id.substr((position === 'start') ? startPrefix.length : endPrefix.length);
        var selector;
        
        if(position == 'start')
            selector = '#' + controlEvent.type + 'StartBox g.note, #' + controlEvent.type + 'StartBox g.rest';
        else
            selector = '#' + controlEvent.type + 'EndBox g.note, #' + controlEvent.type + 'EndBox g.rest';
        
        if(position === 'start') {
            if(mode === 'replace') {
                //console.log('replace startid with ' + noteID);
                resetNotes($(selector));
                paintNotes($(note),placement);
                                
                controlEvent.startIDs.length = 0;
                controlEvent.startIDs.push(noteID);
                
                editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
                
                
            } else if(controlEvent.startIDs.length == 1 && controlEvent.startIDs[0] == noteID) {
                
                //console.log('hitted the current one');
                return;
                
            } else if(controlEvent.startIDs.indexOf(noteID) == -1) {
                
                //console.log('adding new note ' + noteID + ' to possible startIDs');
                controlEvent.startIDs.push(noteID);
                
                resetNotes($(selector));
                
                for(i=0;i < controlEvent.startIDs.length; i++) {
                    paintNotes($('#' + startPrefix + controlEvent.startIDs[i]),'multiResolve')    
                };
                
                editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
                
            } else {
                
                //console.log('removing ' + noteID);
                controlEvent.startIDs = jQuery.grep(controlEvent.startIDs, function(value) {
                    return value != noteID;
                });
                
                resetNotes($(selector));
                
                var isSingleStart = (controlEvent.startIDs.length === 1);
                
                for(i=0;i<controlEvent.startIDs.length;i++) {
                    paintNotes($('#' + startPrefix + controlEvent.startIDs[i]), isSingleStart ? 'ambiguous' : 'multiResolve')    
                };
                
                editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
                
                //todo: rewrite editor with choices, or, in case of just one startid, with only this.
            }
            
            if(controlEvent.startIDs.length < 1)
                alert('something went terribly wrong – currentStarts in guiEditor.js is empty!!!');
            
        // else below: ending note    
        } else {
            if(mode === 'replace') {
                //console.log('replace with ' + noteID);
                resetNotes($(selector));
                paintNotes($(note),placement);
                                
                controlEvent.endIDs.length = 0;
                controlEvent.endIDs.push(noteID);
                
                editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
                
            } else if(controlEvent.endIDs.length == 1 && controlEvent.endIDs[0] == noteID) {
                
                //console.log('hit the current one');
                return;
                
            } else if(controlEvent.endIDs.indexOf(noteID) == -1) {
                
                //console.log('adding ' + noteID);
                controlEvent.endIDs.push(noteID);
                
                resetNotes($(selector));
                
                for(i=0;i < controlEvent.endIDs.length; i++) {
                    paintNotes($('#' + endPrefix + controlEvent.endIDs[i]),'multiResolve')    
                };
                
                editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
                
            } else {
                
                //console.log('removing ' + noteID);
                controlEvent.endIDs = jQuery.grep(controlEvent.endIDs, function(value) {
                    return value != noteID;
                });
                
                resetNotes($(selector));
                for(i=0;i<controlEvent.endIDs.length;i++) {
                    paintNotes($('#' + endPrefix + controlEvent.endIDs[i]),(controlEvent.endIDs.length == 1)? 'ambiguous' : 'multiResolve')    
                };
                
                editor.wrapWithChoice(controlEvent.startIDs,controlEvent.endIDs,controlEvent.tstamp,controlEvent.tstamp2);
            }
            
            
            if(controlEvent.endIDs.length < 1) 
                alert('something went terribly wrong – currentEnds in guiEditor.js is empty!!!');
        }
    };
    
    var getRendering = function(position){
        
        if(['start','end'].indexOf(position) == -1)
            return;
        
        var staffID;
        var prefix;
        var selector;
        
        if(position === 'start') {
            staffID = controlEvent.startStaffID;
            prefix = startPrefix;
            selector = '#' + controlEvent.type + 'StartBox';
        } else {
            staffID = controlEvent.endStaffID;
            prefix = endPrefix;
            selector = '#' + controlEvent.type + 'EndBox';
        }
        
        new jQuery.ajax('resources/xql/getExtendedStaff.xql', {
            method: 'get',
            data: {path: sourcePath, staffID: staffID, id_prefix: prefix},
            success: function(result) {
                var response = result || '';
                
                var options = JSON.stringify({ 
                    inputFormat: 'mei',
                    pageWidth: $(selector).width() * 3, 
                    pageHeight: 75, 
                    border: 0,
                    ignoreLayout: 0 
                });
                  renderer.setOptions(options);
                  renderer.loadData(response);
                  
                  var svg = renderer.renderPage(1,'');
                  
                  $(selector).html(svg);
                  $(selector + ' g.page-scale').attr('transform','scale(.35,.35)');
                  
                  var paintSelector = new Array();
                  paintSelector.length = 0;
                  
                  if(position === 'start') {
                      for(var i=0;i<controlEvent.startIDs.length;i++) {
                          paintSelector.push('#' + prefix + controlEvent.startIDs[i]);
                      }
                  } else {
                      for(var i=0;i<controlEvent.endIDs.length;i++) {
                          paintSelector.push('#' + prefix + controlEvent.endIDs[i]);
                      }
                  }
                  
                  paintNotes($(paintSelector.join()),placement);
                  
                  $(selector + ' g.note, ' + selector + ' g.rest').on('click',function(e) {
                     var note = e.currentTarget;
                     
                     setNote(position,note,e.shiftKey ? 'add' : 'replace');
                     e.preventDefault();
                    
                  });
            }
        });
        
    };
    
    var deleteControlEvent = function() {
        if(controlEvent === null)
            return;
        
        var obj = new Object();
        obj.id = controlEvent.id;
        obj.sourcePath = sourcePath;
        obj.operation = 'remove';
        obj.code = '';
        
        unloadControlEvent();
        
        var pos = -1;
        for(var i = 0; i< changedArray.length;i++) {
            if(changedArray[i].id === obj.id)
                pos = i;
        }
        
        if(pos === -1)
            changedArray.push(obj);
        else
            changedArray[pos] = obj;
    
        console.log('deleted current controlEvent (' + obj.id + ')');
    };
    
    var save = function() {
        
        if(changedArray.length === 0)
            return;
            
        var objects = $('<div></div>');
        
        for(var i=0; i<changedArray.length;i++) {
            var object = $('<div></div>', {
                id: changedArray[i].id,
                operation: changedArray[i].operation,
                sourcePath: changedArray[i].sourcePath
            });
            $(object).append(changedArray[i].code);
            $(objects).append($(object));
        }
        
        objects = $('<div></div>').append($(objects));
        
        $.ajax({
            url:'resources/xql/saveMEI.xql',
            type:"POST",
            data:$(objects).html(),
            contentType:"application/xml; charset=utf-8",
            dataType:"xml",
            success: function(){
                //console.log(arguments);
                changedArray = new Array();
            }
        });
    };
    
    return {
        init: init,
        loadControlEvent: loadControlEvent,
        setChanged: setChanged
    }
    
})();