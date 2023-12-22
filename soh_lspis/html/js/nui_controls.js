$(function(){
    ////////////////////////////////
    // EVENT HANDLERS
    ////////////////////////////////
    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case 'open':
                openGUI(event.data.user);
                break;
            case 'close':
                closeGUI();
                break;
            case 'bolos':
                listBOLOS(event.data);
                break;
            case 'warrants':
                listWarrants(event.data);
                break;
            case 'name_search_results':
                nameSearchResults(event.data);
                break;
            case 'plate_search_results':
                plateSearchResults(event.data);
                break;
            case 'plate_search_nearest':
                plateSearchNearest(event.data);
                break;
            case 'file_bolo_result':
                fileBoloResult(event.data);
                break;
            case 'file_warrant_result':
                fileWarrantResult(event.data);
                break;
            case 'file_record_result':
                fileRecordResult(event.data);
                break;
            default:
                console.log("##### [LSPIS DEBUG]: {message switch} got invalid input: " + event + ' #####');
                break;
        }
    }, false);

    ////////////////////////////////
	// CLICK HANDLERS
    ////////////////////////////////
    /* Exit Button */
	$('#exit_gui').click(function(){
		$('.main-gui').css('display', 'none');
        $('#nav-menu').css('width', '0');
        hideAllGUI();
		hideNav();
        $.post('http://soh_lspis/NUIFocusHandler', JSON.stringify("close"));
	});
    
    /* BOLO Button */
	$('#bolo-btn').click(function(){
		hideAllGUI();
		hideNav();
	
        $('#bolo-gui').fadeIn(1000);
		$.post('http://soh_lspis/NUIFetchBolos', JSON.stringify({}));
    });

    /* Warrants Button */
    $('#warrants-btn').click(function(){
		hideAllGUI();
		hideNav();
	
        $('#warrants-gui').fadeIn(1000);
		$.post('http://soh_lspis/NUIFetchWarrants', JSON.stringify({}));
    });
    
    /* Name Search Button */
    $('#name-search-btn').click(function(){
        hideAllGUI();
        hideNav();
        
        $('#name-search-gui').fadeIn(1000);
    });

    /* Plate Search Button */
    $('#plate-search-btn').click(function(){
        hideAllGUI();
        hideNav();

        $.post('http://soh_lspis/NUINearPlates', JSON.stringify({}));
        $('#plate-search-gui').fadeIn(1000);
    });

    /* File BOLO's Button */
    $('#file-bolo-btn').click(function(){
        hideAllGUI();
        hideNav();
        
        $('#file-bolo-gui').fadeIn(1000);
    });

    /* File Warrant Button */
    $('#file-warrant-btn').click(function(){
        hideAllGUI();
		hideNav();
        
        $('#file-warrant-gui').fadeIn(1000);
    });

    /* File Record Button */
    $('#file-record-btn').click(function(){
        hideAllGUI();
		hideNav();
        
        $('#file-record-gui').fadeIn(1000);
    });

    /* Edit BOLO's Button */
    $('#edit-bolo-btn').click(function(){
        hideAllGUI();
        hideNav();
        
        $('#edit-bolo-gui').fadeIn(1000);
    });

    /* Edit Warrant Button */
    $('#edit-warrant-btn').click(function(){
        hideAllGUI();
		hideNav();
        
        $('#edit-warrant-gui').fadeIn(1000);
    });

    /* Edit Record Button */
    $('#edit-record-btn').click(function(){
        hideAllGUI();
		hideNav();
        
        $('#edit-record-gui').fadeIn(1000);
    });
});

////////////////////////////////
// FUNCTIONS
////////////////////////////////
function hideAllGUI() {
    // Hide menus incase open
        $('#bolo-gui').hide();
        $('#warrants-gui').hide();
        $('#name-search-gui').hide();
        $('#name-search-results-gui').hide();
        $('#plate-search-gui').hide();
        $('#plate-search-results-gui').hide();
        $('#file-bolo-gui').hide();
        $('#file-warrant-gui').hide();
        $('#file-record-gui').hide();
        $('#edit-bolo-gui').hide();
        $('#edit-warrant-gui').hide();
        $('#edit-record-gui').hide();
        $('#welcome-gui').hide();
}

function notifyBarAdd(bar, text){
    $(bar).html('<center>' + text + '</center>');

    var passIt = bar;
    setTimeout(function() {
        notifyBarRemove(passIt);
    }, 3000);
}

function notifyBarRemove(bar) {
    $(bar).html('');
}

function openGUI(user) {
    $('.main-gui').css('display', 'block');
    $('body').css('display', 'block');
    $('html').css('display', 'block');

    $('.main-gui').hide();
    $('body').hide();
    $('html').hide();

    $('.main-gui').fadeIn(200);
    $('body').fadeIn(300);
    $('html').fadeIn(400);

    //showNav();
    hideAllGUI();
    hideNav('welcome');

    switch (user) {
        case 'police':
            /* Show Full System */
            $('#userType').html(
                '&nbsp;You are logged in as an On-Duty Officer.' + '<br/>' +
                '&nbsp;Which grants you full access to file and edit, reports, bolos, and warrants.'
            );
            break;
        case 'police_offDuty':
            /* Show System minus ability to enter / edit reports */
            $('#userType').html(
                '&nbsp;You are logged in as an Off-Duty Officer.' + '<br/>' +
                '&nbsp;You cannot file or edit reports, everything else is accessible.'
            );

            // ACTIVATE BEFORE RELEASE
            /*
            $('#file-bolo-btn').hide();
            $('#file-warrant-btn').hide();
            $('#file-record-btn').hide();
            $('#edit-bolo-btn').hide();
            $('#edit-warrant-btn').hide();
            $('#edit-record-btn').hide();
            //$('#topSpacer').hide();
            $('#bottomSpacer').hide();
            */
            break;
        case 'civilian':
            /* Show only name search */
            $('#userType').html(
                '&nbsp;You are logged in as a Civilian.' + '<br/>' +
                '&nbsp;You are able to look at Public Records via the Name Search'
            );

            // ACTIVATE BEFORE RELEASE
            /*
            $('#bolo-btn').hide();
            $('#warrants-btn').hide();
            $('#plate-search-btn').hide();
            $('#file-bolo-btn').hide();
            $('#file-warrant-btn').hide();
            $('#file-record-btn').hide();
            $('#edit-bolo-btn').hide();
            $('#edit-warrant-btn').hide();
            $('#edit-record-btn').hide();
            $('#topSpacer').hide();
            $('#bottomSpacer').hide();
            */
            break;
        default:
            console.log("##### [LSPIS DEBUG]: {user switch} got invalid input: " + user + ' #####');
            break;
    }
}

function closeGUI() {
    $('#main-gui').css('display', 'none');
    $('body').css('display', 'none');
    $('html').css('display', 'none');
}

function showNav() {
    document.getElementById('nav-menu').style.width = "200px";
    hideAllGUI();
    $('#welcome-gui').fadeOut(300);
}

function hideNav(butNot) {
    document.getElementById('nav-menu').style.width = "0";

    if (butNot == 'welcome') {
        $('#welcome-gui').fadeIn(300);
    }
}

function listBOLOS(data) {
    $('#bolo-info').html('')

    if (data.list == 'empty') {
        $('#bolo-info').html(
            '<tr>' + 
                '<td> </td>' +
                '<td>&nbsp;&nbsp;&nbsp;</td>' +
                '<td><center> NO BOLOS CURRENTLY ON FILE </center></td>' +
                '<td>&nbsp;&nbsp;&nbsp;</td>' +
                '<td> </td>' +
            '</tr>'
        );
    } else {
        Object.keys(data.list).forEach(key => {
            $('#bolo-info').append(
                '<tr>' + 
                    '<td>' + data.list[key].reportId + '</td>' +
                    '<td>&nbsp;&nbsp;&nbsp;</td>' +
                    '<td>' + data.list[key].report + '</td>' +
                    '<td>&nbsp;&nbsp;&nbsp;</td>' +
                    '<td>' + data.list[key].issuedBy + '</td>' +
                '</tr>'
            );
        });
    }
    
}

function listWarrants(data) {
    $('#warrants-info').html('');

    if (data.list == 'empty') {
        $('#warrants-info').html(
            '<tr>' + 
                '<td> </td>' +
                '<td>&nbsp;&nbsp;&nbsp;</td>' +
                '<td><center> NO WARRANTS CURRENTLY ON FILE </center></td>' +
                '<td>&nbsp;&nbsp;&nbsp;</td>' +
                '<td> </td>' +
            '</tr>'
        );
    } else {
        Object.keys(data.list).forEach(key => {
            var status = data.list[key].status
            var statusSTR = '<td>'

            if (status == 'ACTIVE') {
                statusSTR = '<td style=color:red;>'
            } else {
                statusSTR = '<td style=color:green;>'
            }

            $('#warrants-info').append(
                '<tr>' + 
                    '<td>' + data.list[key].warrantId + '</td>' +
                    '<td>&nbsp;&nbsp;&nbsp;</td>' +
                    '<td>' + data.list[key].name + '</td>' +
                    '<td>&nbsp;&nbsp;&nbsp;</td>' +
                    '<td>' + data.list[key].details + '</td>' +
                    '<td>&nbsp;&nbsp;&nbsp;</td>' +
                    statusSTR + data.list[key].status + '</td>' +
                    '<td>&nbsp;&nbsp;&nbsp;</td>' +
                    '<td>' + data.list[key].issuedBy + '</td>' +
                '</tr>'
            );
        });
    }
}

function nameSearch(firstName, lastName) {
    if (firstName.length < 1 || lastName.length < 1) {
        notifyBarAdd('#name-search-notification', '<h2> First and Last name must be filled out. </h2>')
    } else {
        $.post('http://soh_lspis/NUINameSearch', JSON.stringify({firstName, lastName}));
    }
}

function nameSearchResults(data) {
    if (data.list == 'invalid name') {
        notifyBarAdd('#name-search-notification', '<h3> Found no results for that name.</h3>')
    } else {
        $('#name-search-gui').fadeOut(1000);
        $('#name-search-results-gui').fadeIn(1000);
    }

    Object.keys(data.list).forEach(key => {
        var jailStatus = data.list[key].jail;
        var jailSTR = '';
        if (jailStatus > 0) {
            jailSTR = jailStatus + ' months remaining';
        } else {
            jailSTR = 'Not Incarcerated';
        }

        var sex = data.list[key].sex;
        var sexSTR = '';
        if (sex == 'm') {
            sexSTR = 'Male'
        } else {
            sexSTR = 'Female'
        }

        $('#name-search-results-box-left').html(
            '<b>--------------- Information ---------------</b>' + '<br/>' +
            'First Name: ' + data.list[key].firstname + '<br/>' +
            'Last Name: ' + data.list[key].lastname + '<br/>' +
            'Sex: ' + sexSTR + '<br/>' +
            'DOB: ' + data.list[key].dob + '<br/>' +
            'Height: ' + data.list[key].height + 'cm<br/>' +
            'Phone Number: ' + data.list[key].phonenumber + '<br/>' +
            'Address: ' + data.list[key].address + '<br/>'
        );

        $('#name-search-results-box-right').html(
            '-------------------- Licenses --------------------<br/>' + data.list[key].licenses + '<br/>'
        );

        $('#name-search-results-box-center').html(
            '<center><b>-------------------- Criminal Record --------------------</b></center>' + '&nbsp;' +
            'Jail Status: ' + jailSTR + '<br/>' +
            'Drivers License Status: ' + data.list[key].dlStatus + '<br/>' +
            'Weapons Permit Status: ' + data.list[key].wpStatus + '<br/>' +
            'Parole Status: ' + data.list[key].paroleStatus + '<br/><br/>' +
            'Charges: ' + data.list[key].charges + '<br/><br/>' +
            'Citations: ' + data.list[key].citations + '<br/><br/>' +
            'Arrests: ' + data.list[key].arrests + '<br/><br/>' +
            '<div id="civBlock">Police Notes: ' + data.list[key].notes + '<br/><br/>' +
            'Record Last Updated By: ' + data.list[key].lastUpdatedBy + '<br/></div>'
        );
    });
}

function plateSearch(plateNumber) {
    $('#plate-search-results').html('');
    if (plateNumber.length < 3) {
        notifyBarAdd('#plate-search-notification', '<h2> At least 3 characters are required to lookup a plate number. </h2>')
    } else {
        $.post('http://soh_lspis/NUIPlateSearch', JSON.stringify({plateNumber}))
    }
}

function plateSearchNearest(data) {
    if (data.list != null) {
        Object.keys(data.list).forEach(key => {
            $('#plate-search-nearest').html(
                '<br/><center><b><h4>--------------- Vehicles Near By ---------------</h4></b>' + '<br/>' +
                '     Model: ' + data.list[key].model + '  &nbsp;  ' + 'Plate #: ' + data.list[key].plate + '  &nbsp;  ' +
                '<button type="button" id="plateLookupNearby">Lookup</button></center><br/>'
            );

            $('#plateLookupNearby').click(function() {
                plateSearchLookupNear(data.list[key].plate);
            })

        });
    } else {
        $('#plate-search-nearest').html('No Vehicles Nearby');
        console.log("##### [LSPIS DEBUG]: {plateSearchNearest} got null input: " + data.list + ' #####');
    }
}

function plateSearchLookupNear(plate) {
    var inputF = document.getElementById("plateNumber");

    $('input[type="text"]').val(plate);
    plateSearch(plate);
}

function plateSearchResults(data) {
    if (data.list == 'invalid plate') {
        notifyBarAdd('#plate-search-notification', '<h3> Plate is not registered, vehicle is possibly stolen.</h3>')
        $('#plate-search-results').html('');
    } else {
        Object.keys(data.list).forEach(key => {
            $('#plate-search-results').html(
                '<br/><center><b><h4>--------------- Vehicle Registration ---------------</h4></b>' + '<br/>' +
                'Vehicle is registered as a: ' + data.list[key].model + '<br/>' +
                'Vehicle is registered to: &nbsp;&nbsp;' + data.list[key].firstname + ' ' + data.list[key].lastname + '<br/>' +
                'Vehicles registered plate is: ' + data.list[key].plate + '</center><br/>'
            );
        });
    }
}

function fileBolo(id, report) {
    if (id.length < 1 || report.length < 1) {
        notifyBarAdd('#file-bolo-notification', '<h2> ID & Details must be filled out. </h2>')
    } else {
        $.post('http://soh_lspis/NUIFileBolo', JSON.stringify({id, report}));
    }
}

function fileBoloResult(data) {
    if (data.result == 'success') {
        notifyBarAdd('#file-bolo-notification', '<h2> BOLO has been successfully posted. </h2>')
        $('input[type="text"]').val('');
        $('textarea').val('');
    } else {
        notifyBarAdd('#file-bolo-notification', '<h2> BOLO failed to post to system. Retry </h2>')
    }
}

function fileWarrant(id, name, details) {
    var status = "ACTIVE"

    if (id.length < 1 || name.length < 1 || details.length < 1) {
        notifyBarAdd('#file-warrant-notification', '<h2> Please fill out all of the fields. </h2>')
    } else {
        $.post('http://soh_lspis/NUIFileWarrant', JSON.stringify({id, name, details, status}));
    }
}

function fileWarrantResult(data) {
    if (data.result == 'success') {
        notifyBarAdd('#file-warrant-notification', '<h2> Warrant has been successfully posted. </h2>')

        $('input[type="text"]').val('');
        $('textarea').val('');
    } else {
        notifyBarAdd('#file-warrant-notification', '<h2> Warrant failed to post to system. Retry </h2>')
    }
}

function fileRecord(id, firstName, lastName, dob, height, sex, phoneNumber, address, dlStatus, wlStatus, paroleStatus, charges, citations, arrests, notes) {
    if (id.length < 1 || firstName.length < 1 || lastName.length < 1 || dob.length < 1 || height.length < 1 || sex.length < 1) {
        notifyBarAdd('#file-record-notification', '<h4> Please input at least First, Last, DOB, Height, and Sex. </h4>')
    } else {
        $.post('http://soh_lspis/NUIFileRecord', JSON.stringify({id, firstName, lastName, dob, height, sex, phoneNumber, address, dlStatus, wlStatus, paroleStatus, charges, citations, arrests, notes}));
    }
}

function fileRecordResult(data) {
    if (data.result == 'success') {
        notifyBarAdd('#file-record-notification', '<h2> Record has been successfully posted. </h2>')

        $('input[type="text"]').val('');
        $('input[type="tel"]').val('');
        $('input[type="date"]').val('');
        $('select').val('');
        $('textarea').val('');
    } else {
        notifyBarAdd('#file-record-notification', '<h2> Warrant failed to post to system. Retry </h2>')
    }
}

function editBolo(id) {
    if (id.length < 1) {
        notifyBarAdd('#edit-bolo-notification', '<h4> Enter an ID to search </h4>')
    } else {
        $.post('http://soh_lspis/NUIEditBolo', JSON.stringify({id}));
    }
}

function editBoloResults(data) {
    /*  */
}

function editWarrant(id) {
    if (id.length < 1) {
        notifyBarAdd('#edit-warrant-notification', '<h4> Enter an ID to search </h4>')
    } else {
        $.post('http://soh_lspis/NUIEditWarrant', JSON.stringify({id}));
    }
}

function editWarrantResults(data) {
    /*  */
}

function editRecord(id) {
    if (id.length < 1) {
        notifyBarAdd('#edit-record-notification', '<h4> Enter an ID to search </h4>')
    } else {
        $.post('http://soh_lspis/NUIEditRecord', JSON.stringify({id}));
    }
}

function editRecordResults(data) {
    /*  */
}

////////////////////////////////
// ESC KEYUP
////////////////////////////////
document.onkeyup = function (data) {
	if (data.which == 27) { // Escape key
		$('.main-gui').css('display', 'none')
		$.post('http://soh_lspis/NUIFocusHandler', JSON.stringify("close"));
	}
};