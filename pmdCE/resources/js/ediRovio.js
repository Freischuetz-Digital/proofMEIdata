var registerNoteListeners = function() {
    console.log('init ediRovio.js : registerNoteListeners');

    var currentNote = null;
    
    var highlight = '#ff3333';
    var regularColor = '#000000';
    
    $('g.note').off();

    $('g.note, g.rest').on('click',function(e){
        var note = e.currentTarget;
		    
		if(currentNote && currentNote.id === note.id)
		    return;
		
		currentNote = note;
		
		console.log('current note is ' + currentNote.id);
		
		$('g.note, g.rest').css('fill',regularColor);
		$('g.note *, g.rest *').css('stroke',regularColor);
        $(note).css('fill',highlight);
        $(note).children().css('stroke',highlight);
    });
};