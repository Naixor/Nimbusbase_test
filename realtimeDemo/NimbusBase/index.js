// the content of this file was embeded in index.html
// and goolge chrome extension manifest V2 only allow external js file
// so make it be a standalone file
function readBlob(opt_startByte, opt_stopByte) {

    var files = document.getElementById('files').files;
    if (!files.length) {
        alert('Please select a file!');
        return;
    }

    var file = files[0];
    var start = parseInt(opt_startByte) || 0;
    var stop = parseInt(opt_stopByte) || file.size - 1;

    window.act_file = file;

    var reader = new FileReader();

    // If we use onloadend, we need to check the readyState.
    reader.onloadend = function(evt) {
        if (evt.target.readyState == FileReader.DONE) { // DONE == 2
            console.log(evt)
                window.readfile = evt.target.result;
            document.getElementById('byte_content').textContent = evt.target.result;
            document.getElementById('byte_range').textContent = 
                ['Read bytes: ', start + 1, ' - ', stop + 1,
                ' of ', file.size, ' byte file'].join('');
        }
    };

    var blob = file.slice(start, stop + 1);
    reader.readAsBinaryString(file);
}

window.debug = true

document.querySelector('.readBytesButtons').addEventListener('click', function(evt) {
    if (evt.target.tagName.toLowerCase() == 'button') {
        var startByte = evt.target.getAttribute('data-startbyte');
        var endByte = evt.target.getAttribute('data-endbyte');
        readBlob(startByte, endByte);
    }
}, false);
