$(function () {
	$("#code").focus();

	$("#code").keydown(function (e) {
		if(e.keyCode === 9) {
			e.preventDefault();
		}
	});

	$("#logo").dblclick(function (e) {
		e.preventDefault();
		$("#code").focus();

		var c = confirm("Are you sure you want to render your code?\n\nYou will not be able to come back to it.");
		if(c) {
			document.getElementsByTagName('html')[0].innerHTML = $('#code').val();
			var scripts = document.getElementsByTagName("script");
	    for (var i = 0; i < scripts.length; i++) {
        if (scripts[i].src != "") {
          var tag = document.createElement("script");
          tag.src = scripts[i].src;
          document.getElementsByTagName("head")[0].appendChild(tag);
        } else {
          eval(scripts[i].innerHTML);
        }
	    }
		}

	});

	window.addEventListener("beforeunload", function (e) {
		var confirmationMessage = "Are you sure you want to leave the page? All your code will be lost!";

		(e || window.event).returnValue = confirmationMessage;     //Gecko + IE
		return confirmationMessage;                                //Gecko + Webkit, Safari, Chrome etc.
	});
});
