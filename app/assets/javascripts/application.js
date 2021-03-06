// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require_tree ./lib
//= require_tree .


$(function(){
  "use strict";
  $('.admin-edit .tag').live('click', function(){
    var elem = $(this);
    var tag  = elem.find('.tag-text, .tag-nub');
    var remove_category = '';
    remove_category = $('#article_delete_category');
    remove_category.val(tag.clone().find('*').remove().end().text().trim());
    tag.remove();
    $('.tagform form').submit();
  });
  if($('.alert').length > 0){
    $('.app .alert').delay(5000).fadeOut();
    $('.admin .alert').delay(5000).slideUp();
  }
  var submit = $('.action-pane .submit');
  if(submit.length > 0){
    submit.click(function(){
      $('.edit_article').submit();
      return false;
    });
  }
  $('.alert .close').click(function(){
    $(this).parent().remove();
    return false;
  });
  $('.adv-options-link').click(function(){
    $('.advanced-options').slideToggle('fast');
    return false;
  });
  if($('.advanced-options input[value!=""], .advanced-options select option[value!=""]:selected').length > 2){
    $('.advanced-options').show();
  }

  window.next_id = $("[data-next_id]").data("next_id");
  window.next_key = $("[data-next_key]").data("next_key");
});