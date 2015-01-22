// alert(1);
function open_socket() {
    var socket = new WebSocket("ws://localhost:3000/socket");
    socket.onmessage = function(event) {
        var incomingMessage = event.data;
        var data = JSON.parse(incomingMessage);
        var action = data.action;
        switch (action) {
            case 'field_was_created':
                show_field(data);
                break;
            case 'path':
                mark_path(data);
                break;
        }

    };
    return socket;
}

function create_field (argument) {
    var data = {
        action : "create_field",
        x : $('#input_x').val(),
        y : $('#input_y').val(),
    };
    send(data);
}
function show_field (data) {
    $('.size_input').addClass('hide');
    $(data.field).each(function(i,row) {
        $('.div__for_field').append('<div class="row" data-row="' + i +'"></div>')
        var new_row = $('[data-row=' + i + ']');
        $(row).each(function(j, cell) {
            var id = i + '-' + j;
            new_row.append(
                '<div class="cell"><div class="kernel enabled" id="' + id + '" data-row="' + i +'" data-column="' + j +'"></div></div>');
        });
    });
    $('.div__for_field').selectable({filter: ".kernel"});
    $('#mark-disabled-button').removeClass('hide').click(function(ev) {
        $('.kernel.ui-selected').each(function(i,v) {
            tougle_blocked($(v),false);
        }).removeClass('ui-selected');
    });
    $('#mark-enabled-button').removeClass('hide').click(function(ev) {
        $('.kernel.ui-selected').each(function(i,v) {
            tougle_blocked($(v),true);
        }).removeClass('ui-selected');
    });
    $('#start-button').addClass('hide').click(function(ev) {
        $('#go-button').addClass('hide');
        $('#mark-enabled-button').addClass('hide');
        $('#mark-disabled-button').addClass('hide');
        $('.div__for_field').selectable({filter: ".kernel"});
    });
    $('#go-button').removeClass('hide').click(function(ev) {
        $('.kernel.ui-selected').removeClass('ui-selected');
        $('#mark-enabled-button').addClass('hide');
        $('#mark-disabled-button').addClass('hide');
        $('#go-button').addClass('hide');
        $('.div__for_field').selectable( "destroy" );
        $('#notificator').text('Выберете начальную точку');
        $('.kernel').click(function(ev) {
            var el = $(ev.target);
            mark_start({
                x: el.data('column'),
                y: el.data('row'),
            })
            $('#notificator').text('Выберете конечную точку');
            $('.kernel').unbind('click').click(function(ev) {
                var el = $(ev.target);
                go({
                    x: el.data('column'),
                    y: el.data('row'),
                })
            })

        })
    });
}

function tougle_blocked (el, on) {
    var data = {
        x: el.data('column'),
        y: el.data('row')
    }
    data.action = on
        ? 'mark_as_unblocked'
        : 'mark_as_blocked';
    console.log(data);
    if(on) {
        el.removeClass('disabled');
    } else {
        el.addClass('disabled');
    }
    send(data);
}


function send (data) {
    var string = JSON.stringify(data);
    socket.send(string);
}


function mark_start (data) {
    id = data.y + '-' + data.x;
    var el = $('#' + id);
    el.removeClass('enabled').removeClass('disabled');
    data.action = 'mark_start';
    send(data);
}

function go (data) {
    id = data.y + '-' + data.x;
    var el = $('#' + id);
    data.action = 'go';
    send(data);
}

function mark_path (data) {
    var path = $(data.path);
    console.log(path);
    path.each(function(k,v) {
        id = v[1] + '-' + v[0];
        $('#' + id).removeClass('enabled').removeClass('disabled').addClass('path')
    })
}