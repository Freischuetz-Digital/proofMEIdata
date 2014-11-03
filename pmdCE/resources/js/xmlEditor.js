var editor = (function() {

    var editor = null;
    var lastChange = null;
    var isSettingContent = false;
    
    var wellFormedListeners = [];
    var validListeners = [];
    
    var dirty = false;
    var wellFormed = true;
    var valid = false;
    
    var changed = false;
    
    var init = function() {
        $('#validateButton').addClass('disabled');
        $('#saveButton').addClass('disabled');
        
        
		$('#validateButton').on("click", validate);
		$('#saveButton').on("click", save);
		
		$('#setMarkerButton').on("click", setMarker);
		$('#toggleWrapButton').on("click", toggleWrap);
		
		selection.addSelectionChangeListener(onPageChanged);
		controlevents.addControleventChangeListener(onSelectionChanged);
		addWellFormedListener(changeValidateButtonState);
		addWellFormedListener(changeMarketButtonState);
		addValidListener(changeSaveButtonState);
		
		createEditor();
    };
    
    var createEditor = function() {
        editor = ace.edit("aceEditor");
        editor.setTheme("ace/theme/textmate");
        editor.getSession().setUseWrapMode(true);
        editor.getSession().setWrapLimitRange(100,100);
        editor.setReadOnly(true);
        editor.getSession().setMode("ace/mode/xml");
        editor.getSession().on('change', onChange);
        
        editor.selection.on('changeCursor', onChangeCursor);
    };
    
    var onChange = function() {
        
        if(isSettingContent) return;
        
        console.log('editor.onChange()');
        
        changed = true;
        setDirty();

        lastChange = new Date().getTime();
        setTimeout(checkWellFormedness, 1020);
    };
    
    var onChangeCursor = function(event, session) {
        var pos = editor.getCursorPosition();
        var token = editor.getSession().getTokenAt(pos.row, pos.column);
   
        if(token == null) return;
   
        //var id = findXMLID(token.index, pos.row);
        //console.log(id);
    };
    
    var onPageChanged = function() {
        //todo: purge content  
    };
    
    var onSelectionChanged = function(sourcePath, elemID) {
        
        /*new jQuery.ajax('resources/xql/getXML.xql', {
            method: 'get',
            data: {path: sourcePath, staff: staffN},
            success: function(result) {
                var response = result || '';
                isSettingContent = true;
                editor.setValue(response, -1);
                isSettingContent = false;
            }
        });*/
        
        new jQuery.ajax('resources/xql/getControlEvent.xql', {
            method: 'get',
            data: {path: sourcePath, id: elemID},
            success: function(result) {
                var response = result || '';
                
                /*
                doesn't load in xml mode!!!
                
                if(!jQuery.isXMLDoc(result)) {
                    console.log('The file available from ' + sourcePath + ' is not a valid XML file.');
                    return;
                }
                */
                
                //todo: check if changed is true, then put to array of saveable objects
                
                isSettingContent = true;
                editor.setValue(response, -1);
                isSettingContent = false;
            }
        });
        
    };
    
    var checkWellFormedness = function() {
    
        var time = new Date().getTime();
        if(lastChange - time > -1000) return;
        
        var xml = editor.getValue();
        
        new jQuery.ajax('resources/xql/checkWellformedness.xql', {
            method: 'post',
            data: {xml: xml},
            success: function(result) {
                editor.getSession().setAnnotations();
                $('#errors').text(0);
                setWellFormed(true);
                
                
            },
            error: function(result) {
                var msg = result.responseText;
                var error = msg.match(/Fatal \((\d+),(\d+)\) : (.*)\./);
                
                if(error != null) {
                
                    var row = error[1] - 1;
                    var col = error[2];
                    var msg = error[3];
                    
                    editor.getSession().setAnnotations([{row: row, column: col, text: $('<div/>').html(msg).text(), type: 'error'}]);
                    $('#errors').text(1);
                    
                    setWellFormed(false);
                }
            }
        });
    };
    
    var validate = function() {
         
        if($('#validateButton').hasClass('disabled')) return;
 
        var xml = editor.getValue();
        
        new jQuery.ajax('resources/xql/validateMEI.xql', {
            method: 'post',
            data: xml,
            processData: false,
            contentType: 'text/xml; charset=UTF-8',
            success: function(result) {
        
                var status = result.status;
                var annots = [];
                var errorsCount = 0;
                var warningsCount = 0;
    
                if(status === 'invalid') {
                    setValid(false);
                    var message = result.message;
                    
                    if(message instanceof Array) {
                        for(var i = 0; i < message.length; i++) {
                            annots.push({row: result.message[i].line - 1, column: result.message[i].column, text: result.message[i]['#text'], type: result.message[i].level.toLowerCase()});
                            errorsCount++;
                        }
                    }else {
                        annots.push({row: result.message.line - 1, column: result.message.column, text: result.message['#text'], type: result.message.level.toLowerCase()});
                        errorsCount++;
                    }
                }else {
                    setValid(true);
                }
                editor.getSession().setAnnotations(annots);

                $('#errors').text(errorsCount);
                $('#warnings').text(warningsCount);
            }
        });
    };
    
    var save = function() {
    
        if($('#saveButton').hasClass('disabled')) return;
    
        var xml = editor.getValue();
        
        var params = selection.getSelectedStaffParameters();
        
        new jQuery.ajax('resources/xql/saveMEI.xql?staffN=' + params.staffN + '&path=' + params.sourcePath, {
            method: 'post',
            data: xml,
            processData: false,
            contentType: 'text/xml; charset=UTF-8',
            success: function(result) {
        
                var status = result.status;
                var annots = [];
                var errorsCount = 0;
                var warningsCount = 0;
    
                if(status === 'invalid') {
                    setValid(false);
                    var message = result.message;
                    
                    if(message instanceof Array) {
                        for(var i = 0; i < message.length; i++) {
                            annots.push({row: result.message[i].line - 1, column: result.message[i].column, text: result.message[i]['#text'], type: result.message[i].level.toLowerCase()});
                            errorsCount++;
                        }
                    }else {
                        annots.push({row: result.message.line - 1, column: result.message.column, text: result.message['#text'], type: result.message.level.toLowerCase()});
                        errorsCount++;
                    }
                }else {
                    setValid(true);
                }
                editor.getSession().setAnnotations(annots);

                $('#errors').text(errorsCount);
                $('#warnings').text(warningsCount);
            }
        });
    };
    
    var setDirty = function() {
        dirty = true;
        setWellFormed(false);
        setValid(false);
    };
    
    var setWellFormed = function(state) {
        wellFormed = state;
        
        $.each(wellFormedListeners, function(index, listener) {
            listener(wellFormed);
        });
    };

    var setValid = function(state) {
        valid = state;
        
        $.each(validListeners, function(index, listener) {
            listener(valid);
        });
    };

    var highlightById = function(id) {
    
        editor.clearSelection();
        
        editor.$search.set({
            wrap: false,
            needle: '<[^>]* xml:id="' + id + '"[^>]*/?>',
            regExp: true
        });
    
        var result = editor.$search.findAll(editor.getSession());
        if(result.length > 0) {
            //TODO: findClosingTag('</staff>', startRow);
            editor.selection.setSelectionRange(result[0]);
        }
    };
    
    var toggleWrap = function() {
        var active = !$('#toggleWrapButton').hasClass('active');
        editor.getSession().setUseWrapMode(active);
    };
    
    var getEditorValue = function() {
        return editor.getValue();
    };
    
    var addWellFormedListener = function(listener) {
        wellFormedListeners.push(listener);
    };
    
    var changeValidateButtonState = function() {
        if(wellFormed)
            $('#validateButton').removeClass('disabled');
        else
            $('#validateButton').addClass('disabled');
    };
    
    var changeMarketButtonState = function() {
        if(wellFormed)
            $('#setMarkerButton').removeClass('disabled');
        else
            $('#setMarkerButton').addClass('disabled');
    };

    var addValidListener = function(listener) {
        validListeners.push(listener);
    };
    
    var changeSaveButtonState = function() {
        if(valid)
            $('#saveButton').removeClass('disabled');
        else
            $('#saveButton').addClass('disabled');
    };
    
    var setMarker = function() {
        
        if($('#setMarkerButton').hasClass('disabled')) return;
        
        var date = new Date();
        var months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
        date = date.getFullYear() + '-' + months[date.getMonth()] + '-' + (date.getDate() < 10?'0':'') + date.getDate();
        
        var pos = editor.getCursorPosition();
        var insertPos = {row: pos.row, column: pos.column};
        
        var token = editor.getSession().getTokenAt(pos.row, pos.column);
        
        if(token.type == 'meta.tag' && token.start == pos.column) {
            //vor einem öffnenden Tag
        
        }else if(token.type == 'meta.tag' && token.start + token.value.length == pos.column) {
            //zwischen (<|</) und Tagname
            insertPos.column = token.start;
        
        }else if(token.type == 'meta.tag' && token.start + token.value.length > pos.column) {
            //zwischen < und /
            insertPos.column = token.start;
        
        }else if(token.type == 'meta.tag.r' && token.start + token.value.length == pos.column) {
            //direkt hinter >
            
        }else if(token.type == 'meta.tag.r') {
            //direkt in />
            insertPos = findStartTag(token.index, pos.row);
            
        }else if(token.type == 'meta.tag.tag-name') {
            //mitten in einem Tagname oder direkt dahinter
            insertPos = findStartTag(token.index, pos.row);
            
        }else if(token.type == 'entity.other.attribute-name') {
            //mitten in einem Attributnamen oder direkt dahinter
            insertPos = findStartTag(token.index, pos.row);            
            
        }else if(token.type == 'keyword.operator') {
            //hinter einem Keyword
            insertPos = findStartTag(token.index, pos.row);
           
        }else if(token.type == 'string') {
            //in einem Attributwert
            insertPos = findStartTag(token.index, pos.row);    

        }else if(token.type == 'text') {
            //Text
            var index = token.index - 1;
            var tokens = editor.getSession().getTokens(pos.row);
            var prev = tokens[index];
            var line = pos.row;
            
            if(typeof prev === 'undefined') {
                line--;
                while(line >= 0) {
                    tokens = editor.getSession().getTokens(line);
                    index = tokens.length - 1;
                    if(tokens[index].type != 'text' || !tokens[index].value.match(/^\s+$/))
                        break;
                        
                    line--;
                }
            }
            
            if(tokens[index].type == 'text') {
                //im Textknoten
                
            }else if(tokens[index].type == 'meta.tag.r') {
                //im Textknoten
                
            }else if(tokens[index].type == 'string') {
                //zwischen Attributen
                insertPos = findStartTag(index, line);            
                
            }else if(tokens[index].type == 'meta.tag.tag-name') {
                //zwischen Attribut und Tagname
                insertPos = findStartTag(index, line);            
            }
        
        }else {
            console.log('ich weiß nicht, wohin ich schreiben kann (type, start, value.length, pos): ' + token.type + ' ' + token.start + ' ' + token.value.length + ' ' + pos.column);
            return;
        }
        
        var space = '';
        for(var i = 0; i < insertPos.column; i++) space += ' ';
        
        editor.getSession().insert({row: insertPos.row, column:insertPos.column}, '<?freidi_pmd\n' + space + 'date(' + date + ')\n' + space + '\n' + space +'?>');
        editor.moveCursorTo(insertPos.row + 2, space.length);
        editor.clearSelection();
        
        editor.focus();
    };
    
    var findStartTag = function(index, line) {
        var tokens = editor.getSession().getTokens(line);
        
        index--;
           
        while(index >= 0 && line >= 0) {
            var token = tokens[index];
            
            if(typeof tokens[index] == 'undefined') {
                line--;
                tokens = editor.getSession().getTokens(line);
                index = tokens.length - 1; 
            
            }else {
                if(token.type == 'meta.tag') {
                    var start = token.start;
                    if(typeof start == 'undefined') {
                        start = 0;
                        index--;
                        while(index >= 0) {
                            start += tokens[index].value.length;
                            index--;
                        }
                    }
                    
                    return {row: line, column: start};
                }else
                    index--;
            }
        }
        
        return null;
    };
    
    var findTagName = function(index, line) {
        var tokens = editor.getSession().getTokens(line);
        
        index--;
           
        while(index >= 0 && line >= 0) {
            var token = tokens[index];
            
            if(typeof tokens[index] == 'undefined') {
                line--;
                tokens = editor.getSession().getTokens(line);
                index = tokens.length - 1; 
            
            }else {
                if(token.type == 'meta.tag.tag-name') {
                    return token.value;
                }else
                    index--;
            }
        }
        
        return null;
    };
    
    
 /**JK ab hier**/   
    
    var setAttribute = function(attribute, value) {
        editor.clearSelection();
        
        
        //todo: works only for first replacement…
        console.log('editor.setAttribute(' + attribute + ',' + value + ')');
        
        editor.findAll(' ' + attribute + '="[^"]*"',{
            wrap: false,
            regExp: true
        });
        
        editor.replaceAll(' ' + attribute + '="' + value + '"');
        guiEditor.setChanged();
    };
    
    var wrapWithChoice = function(startIDs,endIDs,tstamp,tstamp2) {
        var current = editor.getValue();
        
        //all arrays need to be joined when transmitted to eXist
        var startIDs = startIDs.join();
        var endIDs = endIDs.join();
        var tstamp = tstamp;
        var tstamp2 = tstamp2;
        
        new jQuery.ajax('resources/xql/getElementWithChoice.xql', {
            method: 'get',
            data: {xml: current, startIDs: startIDs, endIDs: endIDs, tstamp: tstamp, tstamp2: tstamp2},
            success: function(result) {
                
                var response = result || '';
                
                //in this case, it is intended to get a changed marker!
                //isSettingContent = true;
                editor.setValue(response, -1);
                //isSettingContent = false;
                
                guiEditor.setChanged();
            }
        });
        
    };
    
    var setBlank = function() {
        isSettingContent = true;
        editor.setValue('', -1);
        isSettingContent = false;
    };
    
    var getTemplate = function(type,id) {
        new jQuery.ajax('resources/xql/getTemplate.xql', {
            method: 'get',
            data: {type: type, id: id},
            success: function(result) {
                
                var response = result || '';
                
                //in this case, it is intended to get a changed marker!
                //isSettingContent = true;
                editor.setValue(response, -1);
                //isSettingContent = false;
                
                guiEditor.setChanged();
            }
        });
    };
    
    return {
        addValidListener: addValidListener,
        addWellFormedListener: addWellFormedListener,
        init: init,
        getEditorValue: getEditorValue,
        highlightById: highlightById,
        setAttribute: setAttribute,
        wrapWithChoice: wrapWithChoice,
        setBlank: setBlank,
        getTemplate: getTemplate
    };
})();