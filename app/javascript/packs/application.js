// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import "stylesheets/application"

Rails.start()
Turbolinks.start()
ActiveStorage.start()


// dropdown menu for navbar
document.addEventListener('DOMContentLoaded', function() {
  const menus = document.querySelectorAll('.navbar-burger');
  const dropdowns = document.querySelectorAll('.navbar-menu');

  if (menus.length && dropdowns.length) {
    for (var i = 0; i < menus.length; i++) {
      menus[i].addEventListener('click', function() {
        for (var j = 0; j < dropdowns.length; j++) {
          dropdowns[j].classList.toggle('hidden');
        }
      });
    }
  }
});