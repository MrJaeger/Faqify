# Faqify

Allowing any site to have a user-driven FAQ system.

## Usage

1. Simply grab both the js/coffee file as well as the scss/css files and stick them in the head of your page.

    ```html
    <script type="text/javascript" src="faqify.js"></script>
    <link href="faqify.css" rel="stylesheet" />
    ```
2. Pick a number that you think will be pretty unique.  A good suggestion is running Math.random() then usin all the digits after the decimal point.  Then instantiate a faqify class passing in the number and you're good to go!

	```javascript
	faqify = new Faqify('Your number here')
	```

## Limitations/Security Issues

Currently there is no security associated with using faqify.  Anyone who knows the key (number) you use to instantiate your faqify class can post questions and answers.  Likewise if you lose this number or change it for whatever reason, you will no longer have access to your original FAQ.  But hey at least its easy to use!