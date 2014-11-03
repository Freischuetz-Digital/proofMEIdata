$('#login-form').submit(function(event) {
    
    $.get('doLogin', { username: $('#username').val(), password: $('#password').val() } )
    .done(function(data) {
        if(typeof data.fail != 'undefined') {
            $('#alert-msg').html('<span>Fehler: ' + data.fail + '</span>');
            $('#alert').show();
        }else if(typeof data.user != 'undefined') {
            $('#alert').hide();
            $('#loggedIn').html('<span>Angemeldet als ' + data.user + '</span>');
            $('#login-form').hide();
            $('#loggedIn').show();
            
            var m = window.location.search.match(/path=%2F([^&]*)/);
            
            if(m != null && m[1]) {
                window.location.href = '../' + decodeURI(m[1].replace('%2F', '/'));
            }
        }
    });

    event.preventDefault();
});
            