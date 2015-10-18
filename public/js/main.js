// public/js/main.js

(function($){

	// Custom functions
	$.fn.disableEnterKey = function(){
		$(this).keydown(function(e){
			if(e.keyCode === 9) { e.preventDefault(); }
		});

		return this;
	};

	var showConfirmationDialog = function(){
		return new Promise(function(resolve, reject){
			var confirm_dialog;
			confirm_dialog = confirm("Are you sure you want to submit your code?\n\nYou will not be able to come back to it.");

			if(confirm_dialog == false) {
				reject();
			} else {
				resolve();
			}
		});
	};

	var promptUserForName = function(){
		return new Promise(function(resolve, reject){
			var name_prompt;
			name_prompt = prompt("What's your name?", "", "");

			if(name_prompt === null || name_prompt === "") {
				reject();
			} else {
				resolve(name_prompt);
			}
		});
	};

	var requestToLeavePage = function(){
		return new Promise(function(resolve, reject){
			if(window.hasSubmittedForm === false && $("#submission_html").val().length > 0 && $("body.editor").length > 0) {
				resolve();
			} else {
				reject();
			}
		});
	};

	// Initial state
	window.hasSubmittedForm = false;
	$("#submission_html").focus().disableEnterKey();

	// Submitting their code
	$("button#submit").click(function(e){

		showConfirmationDialog().then(function(){
			// success - get their name
			promptUserForName().then(function(name){
				window.hasSubmittedForm = true;				
				$("input#submission_name").val(name);
				$("button#submit").addClass('progress');
				$("form").submit();
			}, function(){
				alert("You need to enter your name.");
				e.preventDefault();
			});
		}, function(){
			// error - don't do anything because they didn't confirm their submission
			$("#submission_html").focus();
			e.preventDefault();
		});

	});

	// Preventing them from leaving the page.
	window.addEventListener("beforeunload", function(e) {
		requestToLeavePage().then(function(){
			var confirmation_message;
			confirmation_message = "Are you sure you want to leave the page? All your code will be lost!";

			(e || window.event).returnValue = confirmation_message; // Gecko + IE
			return confirmation_message;                            // Gecko + Webkit, Safari, Chrome etc. 
		});
	});

})(jQuery);