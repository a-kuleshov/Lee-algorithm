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
    $('.kernel').click(function(ev) {
        var cell = $(ev.target);
        var data = {
            y : cell.data('row'),
            x : cell.data('column'),
        };
        do_action(data);
    });


}

function send (data) {
    var string = JSON.stringify(data);
    socket.send(string);
}

function do_action (data) {
    action = get_action();
    switch (action) {
        case 'tougle_blocked':
            tougle_blocked(data);
            break;
        case 'mark_start':
            mark_start(data);
            break;
        case 'go':
            go(data);
            break;
    }
}

function get_action () {
    return $('#action :selected').val();
}

function tougle_blocked (data) {
    id = data.y + '-' + data.x;
    var el = $('#' + id);
    if(el.hasClass('enabled')) {
        el.removeClass('enabled').addClass('disabled');
        data.action = 'mark_as_blocked'
    } else {
        el.removeClass('disabled').addClass('enabled');
        data.action = 'mark_as_unblocked';
    }
    send(data);
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