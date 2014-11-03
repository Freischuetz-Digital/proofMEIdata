/*
 * Freischütz-Digital
 * pmd.pitchControl
 * Copyright Johannes Kepper 2012.
 * kepper(at)edirom.de
 * 
 * http://www.github.com/edirom/ediromSourceManager
 * 
 * ## Description & License
 * 
 * This file Javascript for pmd.pitchControl
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
$(document).ready(function() {
    
    selection.init();
    facsimile.init();
    rendering.init();
    editor.init();
    
    selection.load();
});


var selection = (function() {

    var navigation = null;
    var lockReload = null;
    
    var selectionChangeListeners = [];

    var init = function() {
        $('#availSources').change(onChangeSources);
        $('#availMdivs').change(onChangeMdivs);
        $('#availPages').change(onChangePages);
        $('#availVoices').change(onChangeStaves);
        
		$('#btnPrevPage').on("click", prevPage);
		$('#btnNextPage').on("click", nextPage);
		$('#btnStaffAbove').on("click", staffAbove);
		$('#btnStaffBelow').on("click", staffBelow);		
    };
    
    var load = function() {
        new jQuery.ajax('getNavigation.xql', {
            method: 'get',
            success: function(result) {
                navigation = jQuery.parseJSON(result);
                
                setSources();
            }
        });
    };
    
    var loadContents = function() {
        
        var params = getSelectedStaffParameters();
        
        $.each(selectionChangeListeners, function(index, listener) {
            listener(params.sourcePath, params.sourceSigle, params.mdivId, params.staffN);
        });
    };
    
    var nextPage = function() {
        var selected = $("#availPages option:selected");
        var index = $('#availPages option').index(selected);
        
        if(index == $('#availPages option').length - 1) return;
        
        $('#availPages').prop('selectedIndex', index+1);
        $('#availPages').change();
    };
    
    var prevPage = function() {
        var selected = $("#availPages option:selected");
        var index = $('#availPages option').index(selected);
        
        if(index === 0) return;
        
        $('#availPages').prop('selectedIndex', index-1);
        $('#availPages').change();
    };
    
    var staffAbove = function() {
        var selected = $("#availVoices option:selected");
        var index = $('#availVoices option').index(selected);
        
        if(index === 0) return;
        
        $('#availVoices').prop('selectedIndex', index-1);
        $('#availVoices').change();
    };
    
    var staffBelow = function() {
        var selected = $("#availVoices option:selected");
        var index = $('#availVoices option').index(selected);
        
        if(index == $('#availVoices option').length - 1) return;
        
        $('#availVoices').prop('selectedIndex', index+1);
        $('#availVoices').change();
    };    
    
    var onChangeSources = function() {
        var selected = $("#availSources option:selected");
        var sourceIndex = $('#availSources option').index(selected);
        
        setMdivs(sourceIndex);
    };
    
    var onChangeMdivs = function() {
        var selected = $("#availMdivs option:selected");
        var mdivIndex = $('#availMdivs option').index(selected);
                
        selected = $("#availSources option:selected");
        var sourceIndex = $('#availSources option').index(selected);
        
        lockReload = 2;
        
        setPages(sourceIndex, mdivIndex);
        setStaves(sourceIndex, mdivIndex);
    };
    
    var onChangePages = function() {
        lockReload--;
                
        if(lockReload <= 0) loadContents();
    };
    
    var onChangeStaves = function() {
        lockReload--;
                
        if(lockReload <= 0) loadContents();
    };

    var setSources = function() {
        $.each(navigation, function(index, value) {
            var tmpl = jQuery('#templates option').clone();
            tmpl.html(value.sigle);
            $('#availSources').append(tmpl);
        });
        
        $('#availSources').change();
    };
    
    var setMdivs = function(sourceIndex) {
        $('#availMdivs').empty();
        
        $.each(navigation[sourceIndex].mdivs, function(index, value) {
            var tmpl = jQuery('#templates option').clone();
            tmpl.html(value.id);
            $('#availMdivs').append(tmpl);
        });
        
        $('#availMdivs').change();
    };
    
    var setPages = function(sourceIndex, mdivIndex) {
        $('#availPages').empty();
        
        $.each(navigation[sourceIndex].mdivs[mdivIndex].pages, function(index, value) {
            var tmpl = jQuery('#templates option').clone();
            tmpl.html(value.id);
            $('#availPages').append(tmpl);
        });
        
        $('#availPages').change();
    };
    
    var setStaves = function(sourceIndex, mdivIndex) {
        $('#availVoices').empty();
        
        $.each(navigation[sourceIndex].mdivs[mdivIndex].staves, function(index, value) {
            var tmpl = jQuery('#templates option').clone();
            tmpl.html(value.label);
            $('#availVoices').append(tmpl);
        });
        
        $('#availVoices').change();
    };

    var addSelectionChangeListener = function(listener) {
        selectionChangeListeners.push(listener);
    };

    var getSelectedStaffParameters = function() {
        
        var sourceIndex = $('#availSources option').index($("#availSources option:selected"));
        var mdivIndex = $('#availMdivs option').index($("#availMdivs option:selected"));
        var pageIndex = $('#availPages option').index($("#availPages option:selected"));
        var staffIndex = $('#availVoices option').index($("#availVoices option:selected"));
        
        var sourcePath = navigation[sourceIndex].mdivs[mdivIndex].pages[pageIndex].path;
        var sourceSigle = navigation[sourceIndex].sigle;
        var mdivId = navigation[sourceIndex].mdivs[mdivIndex].id;
        var staffN = navigation[sourceIndex].mdivs[mdivIndex].staves[staffIndex].n;
        
        return {
            sourcePath: sourcePath,
            sourceSigle: sourceSigle,
            mdivId: mdivId,
            staffN: staffN
        };
    };

    return {
        init: init,
        load: load,
        addSelectionChangeListener: addSelectionChangeListener,
        getSelectedStaffParameters: getSelectedStaffParameters
    };
})();

var facsimile = (function() {

    var init = function() {
        selection.addSelectionChangeListener(onSelectionChanged);
    };

    var onSelectionChanged = function(sourcePath, sourceSigle, mdivId, staffN) {
        
        new jQuery.ajax('getFacsimile.xql', {
            method: 'get',
            data: {path: sourcePath, staff: staffN},
            success: function(result) {
                var response = result || '';
                $('#facsimileArea img').attr('src', response);
                $('#facsimileArea a').attr('href', response.replace(/\.jpg\?.*$/, '.jpg?dw=1200&amp;amp;mo=rawfile'));
                $(".fancybox").fancybox();
            }
        });
    };

    return {
        init: init
    };
})();

var rendering = (function() {

    var init = function() {
        selection.addSelectionChangeListener(onSelectionChanged);
    };

    var onSelectionChanged = function(sourcePath, sourceSigle, mdivId, staffN) {
        retrieveAndRenderABC(sourcePath, staffN);
    };
    
    var renderXML = function(xml) {
    
        var params = selection.getSelectedStaffParameters();
        retrieveAndRenderABC(params.sourcePath, null, xml);
    };
    
    var retrieveAndRenderABC = function(sourcePath, staffN, xml) {
        
        var options = {
            method: 'get',
            data: {path: sourcePath, staff: staffN}
        };
        if(sourcePath == null || staffN == null)
            options = {
                method: 'post',
                data: xml,
                processData: false,
                contentType: 'text/xml; charset=UTF-8'
            };
        
        new jQuery.ajax('getRendering.xql' + (staffN==null?'?path=' + sourcePath:''), $.extend({
            success: function(result) {
                var response = result || '';
                
                var book = new ABCJS.TuneBook(response);
                var abcParser = new window.ABCJS.parse.Parse();
    
                var div = document.getElementById('rendering');
                if (div) {
                    div.innerHTML = "";
                    abcParser.parse(book.tunes[0].abc, {});
                    var tune = abcParser.getTune();
                    
                    var paper = Raphael(div, 1215, 400);
                    var printer = new ABCJS.write.Printer(paper, {staffwidth: 1150});
                    printer.printABC(tune);
                    
                    printer.addSelectListener({
                        highlight: function(select) {
                            var start = select.startChar;
                            var end = select.endChar;
                            
                            var str = response.substring(0, end);
                            
                            var result = str.substring(str.lastIndexOf('!xml:id="'), end).match(/!xml:id="([^"]*)"/);
                            if(result !== null)
                                editor.highlightById(result[1]);   
                            
                        },
                        modelChanged: function() {
                        }
                    });
                }
            }
        }, options));
    };

    return {
        init: init,
        renderXML: renderXML
    };
})();

var editor = (function() {

    var editor = null;
    var lastChange = null;
    var isSettingContent = false;
    
    var wellFormedListeners = [];
    var validListeners = [];
    
    var dirty = false;
    var wellFormed = true;
    var valid = false;
    
    var init = function() {
        $('#validateButton').addClass('disabled');
        $('#saveButton').addClass('disabled');
        
        
		$('#validateButton').on("click", validate);
		$('#saveButton').on("click", save);
		
		$('#setMarkerButton').on("click", setMarker);
		$('#toggleWrapButton').on("click", toggleWrap);
		
		selection.addSelectionChangeListener(onSelectionChanged);
		addWellFormedListener(changeValidateButtonState);
		addWellFormedListener(changeMarketButtonState);
		addValidListener(changeSaveButtonState);
		
		createEditor();
    };
    
    var createEditor = function() {
        editor = ace.edit("aceEditor");
        editor.setTheme("ace/theme/textmate");
        editor.getSession().setUseWrapMode(false);
        editor.getSession().setMode("ace/mode/xml");
        editor.getSession().on('change', onChange);
        
        editor.selection.on('changeCursor', onChangeCursor);
    };
    
    var onChange = function() {
        
        if(isSettingContent) return;
        
        setDirty();

        lastChange = new Date().getTime();
        setTimeout(checkWellFormedness, 1020);
    };
    
    var onChangeCursor = function(event, session) {
        var pos = editor.getCursorPosition();
        var token = editor.getSession().getTokenAt(pos.row, pos.column);
   
        if(token == null) return;
   
        var id = findXMLID(token.index, pos.row);
        //console.log(id);
    };
    
    var onSelectionChanged = function(sourcePath, sourceSigle, mdivId, staffN) {
        
        new jQuery.ajax('getXML.xql', {
            method: 'get',
            data: {path: sourcePath, staff: staffN},
            success: function(result) {
                var response = result || '';
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
        
        new jQuery.ajax('checkWellformedness.xql', {
            method: 'post',
            data: {xml: xml},
            success: function(result) {
                editor.getSession().setAnnotations();
                $('#errors').text(0);
                setWellFormed(true);
                
                rendering.renderXML(xml);
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
        
        new jQuery.ajax('validateMEI.xql', {
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
        
        new jQuery.ajax('saveMEI.xql?staffN=' + params.staffN + '&path=' + params.sourcePath, {
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
    
    var findXMLID = function(index, line) {
        var name = findTagName(index, line);
        
        if(name == 'note' || name == 'rest' || name == 'mRest')
            console.log('finde id');
        else
            console.log('finde id von nächster Note oder Pause');
    };

    return {
        addValidListener: addValidListener,
        addWellFormedListener: addWellFormedListener,
        init: init,
        getEditorValue: getEditorValue,
        highlightById: highlightById
    };
})();