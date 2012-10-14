class Faqify
	baseUrl: 'http://tranquil-dusk-4165.herokuapp.com'
	isOpen: false

	baseHtml: '<div id="faqify">
		<div id="faqify_header">
			<span>Check out the FAQ</span>
			<div class="arrow_up"></div>
		</div>
		<div id="faqify_actions">
			<span>Ask a Question!</span>
		</div>
		<ul id="faqify_list"></ul>
	</div>
	<div id="faqify_modal"></div>
	<div id="faqify_modal_background"></div>'

	askQuestionHtml: '<div class="remove_modal">X</div>
		<div id="ask_question_modal">
		<h1>Ask a Question</h1>
		<form>
			<label>Title</label>
			<input type="text" name="faqify_title" />
			<label>So what do you need to know?</label>
			<textarea name="faqify_description"></textarea>
			<button id="ask_button">Ask Question</button>
		</form>
		</div>'

	viewQuestionHtml: (question)->
		html = "<div class='remove_modal'>X</div>
		<div id='view_question_modal' data-question_id='#{question._id}'>
		<h2>Q: #{question.title}</h2>
		<p>#{question.description}</p>
		<h2 class='answer_header'>Answers</h2>
		#{if question.answers.length is 0 then '<p class="no_answers">No answers yet</p>' else ''}
		<ul class='answers'></ul>
		<form>
			<textarea placeholder='Post an answer' name='faqify_description'></textarea>
			<button id='answer_button'>Post Answer</button>
		</form>
		</div>"

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
		$('#faqify').css('width', '250px')
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

	saveQuestion: (event)->
		event.preventDefault()
		data =
			title: $('input[name="faqify_title"]').val()
			description: $('textarea[name="faqify_description"]').val()
		baseUrl = @baseUrl
		successCb = (question)=>
			realQuestion = question.question
			@questions.push(realQuestion)
			li = "<li data-question_id='#{realQuestion._id}'>#{realQuestion.title}</li>"
			console.log(li)
			$('#faqify_list').prepend(li)
		errorCb = (a,b,c)-> console.log(a,b,c)
		$.ajax {
			url: "#{baseUrl}/questions"
			data: data
			type: 'POST'
			success: successCb
			error: errorCb
		}

	saveAnswer: (event)->
		event.preventDefault()
		question_id = $('#view_question_modal').data('question_id')
		data =
			description: $('textarea[name="faqify_description"]').val()
			question_id: question_id
		baseUrl = @baseUrl
		successCb = (answer)=>
			realAnswer = answer.answer
			question = @findQuestion(question_id)
			question.answers.push(realAnswer)
			$('#view_question_modal .no_answers').remove()
			answerLi = "<li><div class='faqify_arrow_right'>#{realAnswer.description}</li>"
			$('#view_question_modal .answers').append(answerLi)
		errorCb = (a,b,c)-> console.log(a,b,c)
		$.ajax {
			url: "#{baseUrl}/answers"
			data: data
			type: 'POST'
			success: successCb
			error: errorCb
		}

	bindEvents: ->
		$('#faqify_header').on('click', => if @isOpen is false then @open() else @close())
		$('#faqify_actions span').on('click', => @askQuestion())
		$('#faqify_modal_background').on('click', => @closeModal())
		$(document).on('click', '#ask_question_modal button', (event)=> @saveQuestion(event))
		$(document).on('click', '.remove_modal', => @closeModal())
		$(document).on('click', '#faqify_list li', (event)=> @viewQuestion(event))
		$(document).on('click', '#view_question_modal button', (event)=> @saveAnswer(event))

	populateList: ->
		for question in @questions
			li = "<li data-question_id='#{question._id}'>#{question.title}</li>"
			$('#faqify_list').append(li)

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