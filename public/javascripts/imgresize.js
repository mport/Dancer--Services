(function () {

    $(document).ready( function() {
        
        $('#imgresize-submit').click( function() {
            $('#imgresize-error h3').html(''); // clear previous messages
            _resize_img();
        });

        function _resize_img () {

            $.blockUI.defaults.css = {};           
            $.blockUI({ 
                    css: { 
                            border: 'none',
                            top: '45%',
                            left: '45%',
                        },
                    message: $('#spinner')
            }); 
       
            var form = $('#imgresize-container form');

            if ( ! _valid(form) ) return;

            $.ajax({
                type: 'GET',
                url: form.attr('action'),
                data: form.serialize(),
                contentType: 'application/json',
                success: function(data, status) {
                    if ( ! data.error ) {
                        // Need to explicitly set the dimension, else colorbox would sometimes
                        // misbehave by setting image dimensions to 0
                        var x = $('#imgresize-x input').val();
                        var y = $('#imgresize-y input').val();

                        $.colorbox({html: '<img src="data:'+data.mime+';base64,'+data.image+'"/>', innerWidth: x, innerHeight: y});

                    } else {

                    }
                    $('#imgresize-error h3').html(data.error);
                    $.unblockUI();
                },
                error: function( req, status, error ) {
                    $.unblockUI();
                    $('#imgresize-error h3').html('an undetermined error has occurred');
                }
            });
        }
    });

    function _valid(form) {

        return true;
    }

})();
