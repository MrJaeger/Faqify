// Generated by CoffeeScript 1.3.3
(function() {
  var Faqify;

  Faqify = (function() {

    Faqify.prototype.baseUrl = 'http://localhost:8000';

    Faqify.prototype.isOpen = false;

    Faqify.prototype.baseHtml = '<div id="faqify">\
		<div id="faqify_header">\
			<span>Check out the FAQ</span>\
			<div class="arrow_up"></div>\
		</div>\
		<div id="faqify_actions">\
			<input type="text" placeholder="Search..." id="faqify_search" />\
			<div id="faqify_refresh">\
				<span>Refresh</span>\
			</div>\
		</div>\
		<ul id="faqify_list"></ul>\
	</div>\
	<div id="faqify_modal"></div>\
	<div id="faqify_modal_background"></div>';

    Faqify.prototype.askQuestionHtml = '<div class="remove_modal">X</div>\
		<div id="ask_question_modal">\
		<h1>Ask a Question</h1>\
		<form>\
			<label>Title *</label>\
			<input required type="text" name="faqify_title" />\
			<label>So what do you need to know? *</label>\
			<textarea name="faqify_description"></textarea>\
			<label>Notify me when this question is answered</label>\
			<input type="text" name="faqify_email" placeholder="Enter email here"/>\
			<button id="ask_button">Ask Question</button>\
		</form>\
		</div>';

    Faqify.prototype.viewQuestionHtml = function(question) {
      var html;
      return html = "<div class='remove_modal'>X</div>		<div id='view_question_modal' data-question_id='" + question._id + "'>		<h2>Q: " + question.title + "</h2>		<p id='question_description'>" + question.description + "</p>		" + (question.answers.length === 0 ? '<p class="no_answers">No answers yet</p>' : '') + "		<ul class='answers'></ul>		<form>			<textarea placeholder='Post an answer' name='faqify_description'></textarea>			<button id='answer_button'>Post Answer</button>		</form>		<form id='subscribe_form'>			<input type='text' placeholder='Enter email here' name='faqify_subscribe' />			<button id='subscribe_button'>Subscribe</button>		</div>";
    };

    Faqify.prototype.loadingHtml = '\
		<div id="circleG">\
			<div id="circleG_1" class="circleG"></div>\
			<div id="circleG_2" class="circleG"></div>\
			<div id="circleG_3" class="circleG"></div>\
		</div>\
	';

    Faqify.prototype.savingHtml = function(text) {
      var html;
      return html = "<div id='saving_animated'>			<span class='saving_dot'>" + text + "</span>			<span class='margin_left saving_dot'>.</span>			<span class='saving_dot'>.</span>			<span class='saving_dot'>.</span>		</div>		";
    };

    function Faqify(apiKey) {
      this.apiKey = apiKey;
      $('body').append(this.baseHtml);
      apiKey = this.apiKey;
      $.ajaxSetup({
        headers: {
          faqify_api_key: apiKey
        }
      });
      this.bindEvents();
      this.getQuestions();
    }

    Faqify.prototype.findQuestion = function(_id) {
      var question, _i, _len, _ref;
      _ref = this.questions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        question = _ref[_i];
        if (question._id === _id) {
          return question;
        }
      }
    };

    Faqify.prototype.open = function() {
      $('#faqify_header .arrow_up').removeClass('arrow_up').addClass('arrow_down');
      $('#faqify_actions').show();
      $('#faqify_list').show();
      return this.isOpen = true;
    };

    Faqify.prototype.close = function() {
      $('#faqify').css('width', '177px');
      $('#faqify .arrow_down').removeClass('arrow_down').addClass('arrow_up');
      $('#faqify_actions').hide();
      $('#faqify_list').hide();
      return this.isOpen = false;
    };

    Faqify.prototype.askQuestion = function() {
      var centerModal;
      centerModal = ($('html').width() - 600) / 2;
      $('#faqify_modal').css({
        left: centerModal
      }).html('').html(this.askQuestionHtml).show();
      return $('#faqify_modal_background').css({
        height: $('html').height(),
        width: $('html').width()
      }).show();
    };

    Faqify.prototype.viewQuestion = function(event) {
      var answer, answerLi, centerModal, question, _i, _len, _ref;
      centerModal = ($('html').width() - 600) / 2;
      question = this.findQuestion($(event.currentTarget).data('question_id'));
      $('#faqify_modal').css({
        left: centerModal
      }).html('').html(this.viewQuestionHtml(question));
      _ref = question.answers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        answer = _ref[_i];
        answerLi = "<li><div class='faqify_arrow_right'></div>" + answer.description + "</li>";
        $('#view_question_modal .answers').append(answerLi);
      }
      $('#faqify_modal').show();
      return $('#faqify_modal_background').css({
        height: $('html').height(),
        width: $('html').width()
      }).show();
    };

    Faqify.prototype.closeModal = function() {
      $('#faqify_modal').html('').hide();
      return $('#faqify_modal_background').hide();
    };

    Faqify.prototype.saveSubscription = function(event) {
      var baseUrl, button, currentText, data, emailInput, question_id,
        _this = this;
      event.preventDefault();
      question_id = $('#view_question_modal').data('question_id');
      emailInput = $('input[name="faqify_subscribe"]');
      data = {
        email: emailInput.val() || null,
        question_id: question_id
      };
      if (data.email != null) {
        button = $(event.currentTarget);
        currentText = button.html();
        button.html(this.savingHtml("Subscribing"));
        baseUrl = this.baseUrl;
        return setTimeout(function() {
          var errorCb, successCb;
          successCb = function() {
            emailInput.val('');
            return button.html('Subscribed!');
          };
          errorCb = function(error) {
            var currentColor, errorText;
            currentColor = button.css('background-color');
            button.css('background-color', '#FA4141');
            errorText = error.status === 403 ? "Already Subscribed" : "Oops! Try Again";
            button.html(errorText);
            return setTimeout(function() {
              button.css('background-color', currentColor);
              return button.html(currentText);
            }, 1000);
          };
          return $.ajax({
            url: "" + baseUrl + "/emails",
            data: data,
            type: 'POST',
            success: successCb,
            error: errorCb
          });
        }, 2000);
      }
    };

    Faqify.prototype.saveQuestion = function(event) {
      var baseUrl, button, currentText, data,
        _this = this;
      event.preventDefault();
      data = {
        title: $('input[name="faqify_title"]').val() || null,
        description: $('textarea[name="faqify_description"]').val() || null,
        email: $('input[name="faqify_email"]').val()
      };
      if ((data.title != null) && (data.description != null)) {
        button = $(event.currentTarget);
        currentText = button.html();
        button.html(this.savingHtml("Saving"));
        baseUrl = this.baseUrl;
        return setTimeout(function() {
          var errorCb, successCb;
          successCb = function(question) {
            var li, rQ;
            rQ = question.question;
            _this.questions.push(rQ);
            li = "<li data-question_id='" + rQ._id + "'>" + rQ.title + "</li>";
            $('#ask_question_li ').after(li);
            button.html('Saved!');
            return button.after("<a href='#' id='go_to_new_question' data-question_id='" + rQ._id + "'>Go to Question</a>");
          };
          errorCb = function() {
            var currentColor;
            currentColor = button.css('background-color');
            button.css('background-color', '#FA4141');
            button.html('Oops! Try Again');
            return setTimeout(function() {
              button.css('background-color', currentColor);
              return button.html(currentText);
            }, 1000);
          };
          return $.ajax({
            url: "" + baseUrl + "/questions",
            data: data,
            type: 'POST',
            success: successCb,
            error: errorCb
          });
        }, 2000);
      }
    };

    Faqify.prototype.saveAnswer = function(event) {
      var baseUrl, button, currentText, data, question_id,
        _this = this;
      event.preventDefault();
      question_id = $('#view_question_modal').data('question_id');
      data = {
        description: $('textarea[name="faqify_description"]').val() || null,
        question_id: question_id
      };
      if (data.description != null) {
        button = $(event.currentTarget);
        currentText = button.html();
        console.log(currentText);
        button.html(this.savingHtml("Saving"));
        baseUrl = this.baseUrl;
        return setTimeout(function() {
          var errorCb, successCb;
          successCb = function(answer) {
            var answerLi, question, realAnswer;
            realAnswer = answer.answer;
            question = _this.findQuestion(question_id);
            question.answers.push(realAnswer);
            $('#view_question_modal .no_answers').remove();
            button.html('Saved!');
            answerLi = "<li><div class='faqify_arrow_right'></div>" + realAnswer.description + "</li>";
            return $('#view_question_modal .answers').append(answerLi);
          };
          errorCb = function() {
            var currentColor;
            currentColor = button.css('background-color');
            button.css('background-color', '#FA4141');
            button.html('Oops! Try Again');
            return setTimeout(function() {
              button.css('background-color', currentColor);
              return button.html(currentText);
            }, 1000);
          };
          return $.ajax({
            url: "" + baseUrl + "/answers",
            data: data,
            type: 'POST',
            success: successCb,
            error: errorCb
          });
        }, 2000);
      }
    };

    Faqify.prototype.search = function(event) {
      var search, searchRegEx, searchTerms, term, _i, _len;
      search = $(event.currentTarget).val();
      searchTerms = search.split(' ');
      searchRegEx = "";
      for (_i = 0, _len = searchTerms.length; _i < _len; _i++) {
        term = searchTerms[_i];
        if (term !== "") {
          searchRegEx += "(" + term + ")|";
        }
      }
      searchRegEx = searchRegEx.substring(0, searchRegEx.length - 1);
      return this.populateList(new RegExp(searchRegEx, "gi"));
    };

    Faqify.prototype.refresh = function() {
      var _this = this;
      this.close();
      $('#faqify_header .arrow_up').remove();
      $('#faqify_header').append(this.loadingHtml);
      return setTimeout(function() {
        return _this.getQuestions().then(function() {
          $('#faqify_header #circleG').remove();
          $('#faqify_header').append('<div class="arrow_down"></div>');
          return _this.open();
        });
      }, 1000);
    };

    Faqify.prototype.openQuestion = function(event) {
      var id;
      event.preventDefault();
      id = $(event.currentTarget).data('question_id');
      return $("#faqify li[data-question_id='" + id + "']").click();
    };

    Faqify.prototype.bindEvents = function() {
      var _this = this;
      $(document).on('click', '#faqify_header', function() {
        if (_this.isOpen === false) {
          return _this.open();
        } else {
          return _this.close();
        }
      });
      $(document).on('click', '#faqify_modal_background', function() {
        return _this.closeModal();
      });
      $(document).on('click', '#ask_question', function() {
        return _this.askQuestion();
      });
      $(document).on('click', '#ask_question_modal button', function(event) {
        return _this.saveQuestion(event);
      });
      $(document).on('click', '.remove_modal', function() {
        return _this.closeModal();
      });
      $(document).on('click', '#faqify_list li:not(:first-child)', function(event) {
        return _this.viewQuestion(event);
      });
      $(document).on('click', '#view_question_modal button', function(event) {
        return _this.saveAnswer(event);
      });
      $(document).on('keyup', '#faqify_search', function(event) {
        return _this.search(event);
      });
      $(document).on('click', '#faqify_refresh span', function() {
        return _this.refresh();
      });
      $(document).on('click', '#go_to_new_question', function(event) {
        return _this.openQuestion(event);
      });
      return $(document).on('click', '#subscribe_button', function(event) {
        return _this.saveSubscription(event);
      });
    };

    Faqify.prototype.populateList = function(regex) {
      var askQuestionLi, faqify_list, li, question, _i, _len, _ref, _results;
      if (regex == null) {
        regex = new RegExp("()", "gi");
      }
      faqify_list = $('#faqify_list');
      faqify_list.html('');
      askQuestionLi = "<li id='ask_question_li'><span id='ask_question'>Ask a Question!</span></li>";
      faqify_list.append(askQuestionLi);
      _ref = this.questions;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        question = _ref[_i];
        if (regex.test(question.title)) {
          li = "<li data-question_id='" + question._id + "'>" + question.title + "</li>";
          _results.push(faqify_list.append(li));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Faqify.prototype.getQuestions = function() {
      var baseUrl, errorCb, successCb,
        _this = this;
      baseUrl = this.baseUrl;
      successCb = function(questions) {
        _this.questions = questions.data;
        return _this.populateList();
      };
      errorCb = function(a, b, c) {
        return console.log(a, b, c);
      };
      return $.ajax({
        url: "" + baseUrl + "/questions",
        success: successCb,
        error: errorCb
      });
    };

    return Faqify;

  })();

  window.Faqify = Faqify;

}).call(this);
