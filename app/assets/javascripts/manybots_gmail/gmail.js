// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('.select').each(function() {
    var parent = $(this).parent()
    $(this).load($(this).data('load_url'), function() {
      $('.submit', parent).removeAttr('disabled');
    });
  });
});