(function () {
    $(document).ready( function() {

        var source   = $("#spellcheck-results-template").html();
        var template = Handlebars.compile(source);

        $('#spellcheck-submit').click( function() {
             $('#spellcheck-results').html(''); // clear previous messages
            _check_spelling();
        });

        $('#spellcheck-word input, #spellcheck-num-suggest input').keypress(function(e) {
            if(e.which == 13) {
               _check_spelling(); 
            }

        });

        function _check_spelling () {
            
            var form = $('#spellcheck-container form');

            if ( ! _valid(form) ) return;

            $.ajax({
                type: 'GET',
                url: form.attr('action'),
                data: form.serialize(),
                contentType: 'application/json',
                dataType: 'json',
                success: function(data, status) {
                    $('#spellcheck-results').html(template(data));
                },
                error: function( req, status, error ) {
                    $('#spellcheck-results').html('an undetermined error has occurred');
                }
            });
        }
    });

    function _valid(form) {
        var word = form.find('#spellcheck-word input').val();
        var num_suggest= form.find('#spellcheck-num-suggest input').val();

        if ( isNaN(num_suggest) || num_suggest <= 0 || num_suggest % 1 !== 0) {
            $('#spellcheck-results').html('<h3>number of suggestions must be a positive integer</h3>');
            return false;
        }
        
        if ( word.length === 0 ) {
            $('#spellcheck-results').html('<h3>please specify at least one word to spellcheck</h3>');
            return false;
        }

        return true;
    }

})();
