// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('.email-body').each(function() {
    $(this).load($(this).data("load_url"));
  });
});