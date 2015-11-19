# public/js/app.coffee

NoLight = {
  hasSubmittedForm: false,
  translations: {
    empty_html: 'You need to enter HTML to be able to submit.',
    confirm:    'Are you sure you want to submit your code?\n\nYou will not be able to come back to it.',
    prompt:     'What\'s your name?',
    leave:      'Are you sure you want to leave the page? All your code will be lost!'
  }
}

NoLight.init = ->
  header          = $('header')
  editor          = $('#editor')
  submission_name = $('#submission_name')
  submission_html = $('#submission_html')
  submit_button   = $('#submit')

  chars_count = $('#count #characters em')
  lines_count = $('#count #lines em')

  screen_width    = $(window).width()
  screen_height   = $(window).height()

  submission_html.focus()
  header.width(screen_width)
  editor.width(screen_width - 50).height(screen_height - 180) # This includes padding + the area at the top.

  # Tabbing.
  if typeof tabIndent is 'object'
    tabIndent.render(submission_html[0])
  else
    submission_html.keydown((e) -> e.preventDefault() if e.keyCode is 9)

  # Update character/line count.
  $('#count').click -> $(this).toggleClass('hide')

  submission_html.keyup (e) ->
    chars_count.text submission_html.val().length
    lines_count.text (submission_html.val().match(/\n/g) || []).length
  
  # On submit!
  editor.submit (e) ->
    e.preventDefault()
    e.stopImmediatePropagation()

    submission_html_trimmed = $.trim($('#submission_html').html())
    if submission_html_trimmed.length is 0
      return alert(NoLight.translations['empty_html'])

    # Ask them to confirm + their name.
    NoLight.confirmAndPrompt().then((name) ->
      submit_button.addClass('progress')
      submission_name.val(name)
      NoLight.hasSubmittedForm = true

      # Submit the form!
      setTimeout (-> editor.unbind().find('#submit').click()), 1
    , NoLight.setToOriginalState)

  # Preventing them from leaving the page.
  NoLight.addUnloadListener()

NoLight.setToOriginalState = ->
  $('#submit').removeClass('progress')
  $('#submission_html').focus()

NoLight.addUnloadListener = ->
  window.addEventListener 'beforeunload', (e) ->
    NoLight.attemptToLeavePage().then ->
      event                = e || window.event
      confirmation_message = NoLight.translations['leave']

      (e || window.event).returnValue = confirmation_message
      return confirmation_message

NoLight.confirmAndPrompt = ->
  new Promise (resolve, reject) ->
    confirm_dialog = confirm NoLight.translations['confirm']
    if confirm_dialog
      name_prompt = prompt NoLight.translations['prompt']
      if name_prompt is null || $.trim(name_prompt) is ''
        reject()
      else
        resolve(name_prompt)
    else
      reject()

NoLight.attemptToLeavePage = ->
  new Promise (resolve, reject) ->
    not_submitted_form   = !NoLight.hasSubmittedForm
    submission_html_valid = $('#submission_html').val().length > 0
    body_editor_exists    = $('body.editor').length > 0

    if not_submitted_form && submission_html_valid && body_editor_exists
      resolve()
    else
      reject()

# Run init.
$(document).ready -> NoLight.init()