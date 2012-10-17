class Faqify
	#baseUrl: 'http://tranquil-dusk-4165.herokuapp.com'
	baseUrl: 'http://localhost:8000'
	isOpen: false

	baseHtml: '<div id="faqify">
		<div id="faqify_header">
			<span>Check out the FAQ</span>
			<div class="arrow_up"></div>
		</div>
		<div id="faqify_actions">
			<input type="text" placeholder="Search..." id="faqify_search" />
			<div id="faqify_refresh">
				<span>Refresh</span>
			</div>
		</div>
		<ul id="faqify_list"></ul>
	</div>
	<div id="faqify_modal"></div>
	<div id="faqify_modal_background"></div>'

	askQuestionHtml: '<div class="remove_modal">X</div>
		<div id="ask_question_modal">
		<h1>Ask a Question</h1>
		<form>
			<label>Title *</label>
			<input required type="text" name="faqify_title" />
			<label>So what do you need to know? *</label>
			<textarea name="faqify_description"></textarea>
			<label>Notify me when this question is answered</label>
			<input type="text" name="faqify_email" placeholder="Enter email here"/>
			<button id="ask_button">Ask Question</button>
		</form>
		</div>'

	viewQuestionHtml: (question)->
		html = "<div class='remove_modal'>X</div>
		<div id='view_question_modal' data-question_id='#{question._id}'>
		<h2>Q: #{question.title}</h2>
		<p id='question_description'>#{question.description}</p>
		#{if question.answers.length is 0 then '<p class="no_answers">No answers yet</p>' else ''}
		<ul class='answers'></ul>
		<form>
			<textarea placeholder='Post an answer' name='faqify_description'></textarea>
			<button id='answer_button'>Post Answer</button>
		</form>
		<form id='subscribe_form'>
			<input type='text' placeholder='Enter email here' name='faqify_subscribe' />
			<button id='subscribe_button'>Subscribe</button>
		</div>"

	loadingHtml: '
		<div id="circleG">
			<div id="circleG_1" class="circleG"></div>
			<div id="circleG_2" class="circleG"></div>
			<div id="circleG_3" class="circleG"></div>
		</div>
	'

	savingHtml: (text)->
		html = "<div id='saving_animated'>
			<span class='saving_dot'>#{text}</span>
			<span class='margin_left saving_dot'>.</span>
			<span class='saving_dot'>.</span>
			<span class='saving_dot'>.</span>
		</div>
		"
	constructor: (@apiKey)->
		$('body').append(@baseHtml)
		apiKey = @apiKey
		$.ajaxSetup {
			headers: {faqify_api_key: apiKey}
		}
		@bindEvents()
		@getQuestions()

	findQuestion: (_id)->
		for question in @questions
			if question._id is _id
				return question

	open: ->
		$('#faqify_header .arrow_up').removeClass('arrow_up').addClass('arrow_down')
		$('#faqify_actions').show()
		$('#faqify_list').show()
		@isOpen = true

	close: ->
		$('#faqify').css('width', '177px')
		$('#faqify .arrow_down').removeClass('arrow_down').addClass('arrow_up')
		$('#faqify_actions').hide()
		$('#faqify_list').hide()
		@isOpen = false

	askQuestion: ->
		centerModal = ($('html').width()-600)/2
		$('#faqify_modal').css({left: centerModal}).html('').html(@askQuestionHtml).show()
		$('#faqify_modal_background').css({height: $('html').height(), width: $('html').width()}).show()

	viewQuestion: (event)->
		centerModal = ($('html').width()-600)/2
		question = @findQuestion($(event.currentTarget).data('question_id'))
		$('#faqify_modal').css({left: centerModal}).html('').html(@viewQuestionHtml(question))
		for answer in question.answers
			answerLi = "<li><div class='faqify_arrow_right'></div>#{answer.description}</li>"
			$('#view_question_modal .answers').append(answerLi)
		$('#faqify_modal').show()
		$('#faqify_modal_background').css({height: $('html').height(), width: $('html').width()}).show()

	closeModal: ->
		$('#faqify_modal').html('').hide()
		$('#faqify_modal_background').hide()

	saveSubscription: (event)->
		event.preventDefault()
		question_id = $('#view_question_modal').data('question_id')
		emailInput = $('input[name="faqify_subscribe"]')
		data =
			email: emailInput.val() or null
			question_id: question_id
		if data.email?
			button = $(event.currentTarget)
			currentText = button.html()
			button.html(@savingHtml("Subscribing"))
			baseUrl = @baseUrl
			setTimeout(=>
				successCb = ()=>
					emailInput.val('')
					button.html('Subscribed!')
				errorCb = (error)=>
					currentColor = button.css('background-color')
					button.css('background-color', '#FA4141')
					errorText = if error.status == 403 then "Already Subscribed" else "Oops! Try Again"
					button.html(errorText)
					setTimeout(->
						button.css('background-color', currentColor)
						button.html(currentText)
					, 1000)
				$.ajax {
					url: "#{baseUrl}/emails"
					data: data
					type: 'POST'
					success: successCb
					error: errorCb
				}
			, 2000)

	saveQuestion: (event)->
		event.preventDefault()
		data =
			title: $('input[name="faqify_title"]').val() or null
			description: $('textarea[name="faqify_description"]').val() or null
			email: $('input[name="faqify_email"]').val()
		if data.title? and data.description?
			button = $(event.currentTarget)
			currentText = button.html()
			button.html(@savingHtml("Saving"))
			baseUrl = @baseUrl
			setTimeout(=>
				successCb = (question)=>
					rQ = question.question
					@questions.push(rQ)
					li = "<li data-question_id='#{rQ._id}'>#{rQ.title}</li>"
					$('#ask_question_li ').after(li)
					button.html('Saved!')
					button.after("<a href='#' id='go_to_new_question' data-question_id='#{rQ._id}'>Go to Question</a>")
				errorCb = ()->
					currentColor = button.css('background-color')
					button.css('background-color', '#FA4141')
					button.html('Oops! Try Again')
					setTimeout(->
						button.css('background-color', currentColor)
						button.html(currentText)
					, 1000)

				$.ajax {
					url: "#{baseUrl}/questions"
					data: data
					type: 'POST'
					success: successCb
					error: errorCb
				}
			, 2000)

	saveAnswer: (event)->
		event.preventDefault()
		question_id = $('#view_question_modal').data('question_id')
		data =
			description: $('textarea[name="faqify_description"]').val() or null
			question_id: question_id
		if data.description?
			button = $(event.currentTarget)
			currentText = button.html()
			console.log(currentText)
			button.html(@savingHtml("Saving"))
			baseUrl = @baseUrl
			setTimeout( =>
				successCb = (answer)=>
					realAnswer = answer.answer
					question = @findQuestion(question_id)
					question.answers.push(realAnswer)
					$('#view_question_modal .no_answers').remove()
					button.html('Saved!')
					answerLi = "<li><div class='faqify_arrow_right'></div>#{realAnswer.description}</li>"
					$('#view_question_modal .answers').append(answerLi)
				errorCb = ->
					currentColor = button.css('background-color')
					button.css('background-color', '#FA4141')
					button.html('Oops! Try Again')
					setTimeout(->
						button.css('background-color', currentColor)
						button.html(currentText)
					, 1000)
				$.ajax {
					url: "#{baseUrl}/answers"
					data: data
					type: 'POST'
					success: successCb
					error: errorCb
				}
			, 2000)

	search: (event)->
		search = $(event.currentTarget).val()
		searchTerms = search.split(' ')
		searchRegEx = ""
		for term in searchTerms
			if term != "" then searchRegEx += "(#{term})|"
		searchRegEx = searchRegEx.substring(0, searchRegEx.length-1)
		@populateList(new RegExp(searchRegEx, "gi"))

	refresh: ->
		@close()
		$('#faqify_header .arrow_up').remove()
		$('#faqify_header').append(@loadingHtml)
		setTimeout(=> 
			@getQuestions().then(=>
				$('#faqify_header #circleG').remove()
				$('#faqify_header').append('<div class="arrow_down"></div>')
				@open()
			) 
		, 1000)

	openQuestion: (event)->
		event.preventDefault()
		id = $(event.currentTarget).data('question_id')
		$("#faqify li[data-question_id='#{id}']").click()

	bindEvents: ->
		$(document).on('click', '#faqify_header', => if @isOpen is false then @open() else @close())
		$(document).on('click', '#faqify_modal_background', => @closeModal())
		$(document).on('click', '#ask_question', => @askQuestion())
		$(document).on('click', '#ask_question_modal button', (event)=> @saveQuestion(event))
		$(document).on('click', '.remove_modal', => @closeModal())
		$(document).on('click', '#faqify_list li:not(:first-child)', (event)=> @viewQuestion(event))
		$(document).on('click', '#view_question_modal button', (event)=> @saveAnswer(event))
		$(document).on('keyup', '#faqify_search', (event)=> @search(event))
		$(document).on('click', '#faqify_refresh span', => @refresh())
		$(document).on('click', '#go_to_new_question', (event)=> @openQuestion(event))
		$(document).on('click', '#subscribe_button', (event)=> @saveSubscription(event))

	populateList: (regex = new RegExp("()", "gi"))->
		faqify_list = $('#faqify_list')
		faqify_list.html('')
		askQuestionLi = "<li id='ask_question_li'><span id='ask_question'>Ask a Question!</span></li>"
		faqify_list.append(askQuestionLi)
		for question in @questions
			if regex.test(question.title)
				li = "<li data-question_id='#{question._id}'>#{question.title}</li>"
				faqify_list.append(li)

	getQuestions: ->
		baseUrl = @baseUrl
		successCb = (questions)=> 
			@questions = questions.data
			@populateList()
		errorCb = (a,b,c)-> console.log(a,b,c)
		$.ajax {
			url: "#{baseUrl}/questions"
			success: successCb
			error: errorCb
		}

window.Faqify = Faqify